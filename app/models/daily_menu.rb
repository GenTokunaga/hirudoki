class DailyMenu < ApplicationRecord
  MONTH_FORMAT = /\A(\d{4})-(0[1-9]|1[0-2])\z/

  belongs_to :bento
  has_many :orders, dependent: :restrict_with_error

  validates :served_on, presence: true
  validates :stock_limit, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000 }
  validate :bento_type_must_be_unique_on_served_on
  validate :served_on_and_bento_must_not_change_after_ordered, on: :update

  scope :served_in, ->(dates) { where(served_on: dates) }
  scope :ordered, -> { joins(:bento).order(:served_on, 'bentos.position', :id) }
  scope :on_sale, -> { joins(:bento).where(bentos: { on_sale: true }) }

  def self.parse_month(text, fallback:)
    year, month = text.to_s.match(MONTH_FORMAT)&.captures
    return fallback.beginning_of_month if year.nil?

    Date.new(year.to_i, month.to_i)
  end

  def ordered_quantity
    orders.reject(&:canceled?).sum(&:quantity)
  end

  def remaining_stock
    [stock_limit - ordered_quantity, 0].max
  end

  private

  # NOTE: 弁当タイプは弁当テーブルにしかないため DB の一意制約にできず、アプリ側で確認している（docs/decisions.md 参照）。
  #       同時に登録されると重複しうるが、献立を登録するのは管理者だけなので許容している
  def bento_type_must_be_unique_on_served_on
    return if served_on.blank? || bento.blank?

    duplicated = DailyMenu.joins(:bento)
                          .where(served_on:, bentos: { bento_type: bento.bento_type })
                          .where.not(id:)
                          .exists?
    return unless duplicated

    errors.add(:bento_id, :bento_type_taken,
               served_on: I18n.l(served_on), bento_type: Bento.human_enum_name(:bento_type, bento.bento_type))
  end

  def served_on_and_bento_must_not_change_after_ordered
    return unless (will_save_change_to_served_on? || will_save_change_to_bento_id?) && orders.exists?

    errors.add(:served_on, :ordered_menu_unchangeable) if will_save_change_to_served_on?
    errors.add(:bento_id, :ordered_menu_unchangeable) if will_save_change_to_bento_id?
  end
end
