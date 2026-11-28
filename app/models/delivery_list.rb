class DeliveryList
  attr_reader :served_on

  def initialize(served_on:)
    @served_on = served_on
  end

  def bentos_with_total_quantity
    Bento.joins(daily_menus: :orders).merge(target_orders)
         .group(:id).order(:position, :id)
         .select('bentos.*', 'SUM(orders.quantity) AS total_quantity')
  end

  def orders
    target_orders.joins(:delivery_area).merge(DeliveryArea.ordered).order(:id)
                 .preload(:user, :delivery_area, daily_menu: :bento)
  end

  private

  def target_orders
    Order.not_canceled.joins(:daily_menu).where(daily_menus: { served_on: })
  end
end
