module OrdersHelper
  def quantity_options
    Order::QUANTITY_RANGE.map { ["#{it} 個", it] }
  end

  def delivery_area_options
    DeliveryArea.where(active: true).ordered.map { ["#{it.name}（#{formatted_postal_code(it.postal_code)}）", it.id] }
  end

  def order_status_badge(order)
    label = Order.human_enum_name(:status, order.status)
    case order.status
    when 'ordered' then tag.span label, class: 'badge text-bg-primary'
    when 'received' then tag.span label, class: 'badge text-bg-success'
    else tag.span label, class: 'badge text-bg-secondary'
    end
  end

  def daily_menu_order_button(daily_menu, now: Time.current)
    if !daily_menu.orderable_at?(now)
      disabled_order_button('受付終了')
    elsif daily_menu.remaining_stock.zero?
      disabled_order_button('売り切れ')
    else
      link_to '注文する', new_daily_menu_order_path(daily_menu), class: 'btn btn-sm btn-primary'
    end
  end

  private

  def disabled_order_button(reason)
    tag.button reason, type: 'button', class: 'btn btn-sm btn-outline-secondary', disabled: true
  end
end
