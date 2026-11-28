class SubscriptionOrderGeneration
  include ActiveModel::Model
  include ActiveModel::Attributes

  Skip = Data.define(:subscription, :reason)

  attribute :served_on, :date

  attr_reader :generated_orders, :skips

  validates :served_on, presence: true
  validate :served_on_must_be_generatable

  # NOTE: save や Order#submit と同じく成否を返し、コントローラーで分岐できるようにしている。
  #       結果を返す動詞のメソッドで述語ではないため、? を付ける命名の指摘は外している
  def run(now:) # rubocop:disable Naming/PredicateMethod
    @now = now
    generate_orders if valid?
    errors.empty?
  end

  def weekend?
    served_on.saturday? || served_on.sunday?
  end

  private

  def generate_orders
    @generated_orders = []
    @skips = []
    ActiveRecord::Base.transaction do
      target_subscriptions.each { generate_order_for(it) }
    end
  end

  # NOTE: 同じ日を同時に生成すると、互いの生成済みの注文が見えず二重に作られるため、対象の設定に行ロックを掛けて順番に処理している
  def target_subscriptions
    Subscription.where(active: true, wday: served_on.wday).lock.preload(:user, :delivery_area).order(:id)
  end

  def generate_order_for(subscription)
    daily_menu = daily_menus_by_bento_type[subscription.bento_type]
    reason = skip_reason(subscription, daily_menu)
    if reason
      @skips << Skip.new(subscription:, reason:)
    else
      @generated_orders << subscription.build_order(daily_menu:).tap(&:save!)
    end
  end

  # NOTE: 再実行したときに「すでに生成済み」と分かるよう、生成済みかどうかを最初に確かめている
  def skip_reason(subscription, daily_menu)
    if generated_subscription_ids.include?(subscription.id)
      :already_generated
    elsif daily_menu.nil?
      :no_daily_menu
    elsif !subscription.delivery_area.active?
      :inactive_delivery_area
    elsif ordered_quantity_by_user_id.fetch(subscription.user_id, 0) + subscription.quantity > Order::DAILY_QUANTITY_LIMIT
      :exceeds_daily_limit
    end
  end

  def daily_menus_by_bento_type
    @daily_menus_by_bento_type ||= DailyMenu.on_sale.where(served_on:).preload(:bento).index_by { it.bento.bento_type }
  end

  # NOTE: キャンセル済みの注文も「生成済み」に含める。利用者がキャンセルした注文を、再実行で作り直さないため
  def generated_subscription_ids
    @generated_subscription_ids ||= orders_served_on.where.not(subscription_id: nil).pluck(:subscription_id).to_set
  end

  def ordered_quantity_by_user_id
    @ordered_quantity_by_user_id ||= orders_served_on.not_canceled.group(:user_id).sum(:quantity)
  end

  def orders_served_on
    Order.joins(:daily_menu).where(daily_menus: { served_on: })
  end

  def served_on_must_be_generatable
    return if served_on.blank?

    if served_on < @now.to_date
      errors.add(:served_on, :past)
    elsif @now >= DailyMenu.order_deadline_on(served_on)
      errors.add(:served_on, :deadline_passed, deadline: Rails.configuration.x.hirudoki.order_deadline)
    elsif !DailyMenu.within_orderable_days?(served_on, @now.to_date)
      errors.add(:served_on, :too_far_ahead, days: Rails.configuration.x.hirudoki.orderable_days_ahead)
    end
  end
end
