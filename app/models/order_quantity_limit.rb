class OrderQuantityLimit
  def initialize(order)
    @order = order
  end

  def remaining_stock
    [@order.daily_menu.stock_limit - other_orders_of_daily_menu.sum(:quantity), 0].max
  end

  def ordered_quantity_on_served_on
    other_orders_of_user_on_served_on.sum(:quantity)
  end

  def exceeds_remaining_stock?
    @order.quantity > remaining_stock
  end

  def exceeds_daily_limit?
    ordered_quantity_on_served_on + @order.quantity > Order::DAILY_QUANTITY_LIMIT
  end

  private

  # NOTE: 個数変更では変更前の自分の個数を戻してから判定するため、自分の注文を除いて数えている
  def other_orders_of_daily_menu
    @order.daily_menu.orders.not_canceled.where.not(id: @order.id)
  end

  def other_orders_of_user_on_served_on
    @order.user.orders.not_canceled.where.not(id: @order.id)
          .joins(:daily_menu).where(daily_menus: { served_on: @order.daily_menu.served_on })
  end
end
