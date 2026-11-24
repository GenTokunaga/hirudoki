class Order < ApplicationRecord
  QUANTITY_RANGE = (1..3)
  DAILY_QUANTITY_LIMIT = 3

  enum :status, {
    ordered: 'ordered',
    received: 'received',
    canceled: 'canceled',
  }, default: :ordered, validate: true

  belongs_to :user
  belongs_to :daily_menu
  belongs_to :delivery_area
  belongs_to :subscription, optional: true
  has_one :review, dependent: :restrict_with_error

  validates :quantity, numericality: { only_integer: true, in: QUANTITY_RANGE }
  validates :delivery_address, presence: true, length: { maximum: 255 }
  validates :unit_price, :discount_per_unit, :total_price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # NOTE: 締切や残数は利用者が画面から注文するときだけの条件で、管理者のステータス変更や定期注文の生成には掛けない。
  #       そのため通常の検証には入れず、独自の検証コンテキストで確認している
  with_options on: :submission do
    validate :daily_menu_must_be_orderable
    validate :delivery_area_must_be_active
    validate :quantity_must_be_within_remaining_stock
    validate :quantity_must_be_within_daily_limit
  end

  scope :not_canceled, -> { where.not(status: :canceled) }
  scope :recent, -> { order(created_at: :desc, id: :desc) }

  def price
    OrderPrice.new(unit_price:, discount_per_unit:, quantity:)
  end

  def assign_total_price
    self.total_price = price.total
  end

  def submit(now:)
    @operated_at = now
    self.unit_price = daily_menu.bento.price
    self.discount_per_unit = 0
    assign_total_price if quantity.present?
    save(context: :submission)
  end

  private

  def daily_menu_must_be_orderable
    if !daily_menu.bento.on_sale?
      errors.add(:base, :bento_not_on_sale)
    elsif !daily_menu.before_deadline?(@operated_at)
      errors.add(:base, :deadline_passed, deadline: Rails.configuration.x.hirudoki.order_deadline)
    elsif !daily_menu.within_orderable_days?(@operated_at.to_date)
      errors.add(:base, :too_far_ahead, days: Rails.configuration.x.hirudoki.orderable_days_ahead)
    end
  end

  def delivery_area_must_be_active
    return if delivery_area.nil? || delivery_area.active?

    errors.add(:delivery_area, :inactive)
  end

  def quantity_must_be_within_remaining_stock
    return if quantity.blank?

    remaining_stock = [daily_menu.stock_limit - other_orders_of_daily_menu.sum(:quantity), 0].max
    errors.add(:quantity, :exceeds_remaining_stock, remaining_stock:) if quantity > remaining_stock
  end

  def quantity_must_be_within_daily_limit
    return if quantity.blank?

    ordered_quantity = other_orders_of_user_on_served_on.sum(:quantity)
    return if ordered_quantity + quantity <= DAILY_QUANTITY_LIMIT

    errors.add(:quantity, :exceeds_daily_limit, limit: DAILY_QUANTITY_LIMIT, ordered_quantity:)
  end

  def other_orders_of_daily_menu
    daily_menu.orders.not_canceled.where.not(id:)
  end

  def other_orders_of_user_on_served_on
    user.orders.not_canceled.where.not(id:).joins(:daily_menu).where(daily_menus: { served_on: daily_menu.served_on })
  end
end
