module DeliveryAreasHelper
  def formatted_postal_code(postal_code)
    "〒#{postal_code[0, 3]}-#{postal_code[3, 4]}"
  end

  def delivery_area_status_badge(delivery_area)
    if delivery_area.active?
      tag.span '有効', class: 'badge text-bg-success'
    else
      tag.span '無効', class: 'badge text-bg-secondary'
    end
  end
end
