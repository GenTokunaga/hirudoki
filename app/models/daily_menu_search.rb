class DailyMenuSearch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :served_on, :date
  attribute :bento_type, :string

  def period(today:)
    return served_on..served_on if served_on

    today..(today + Rails.configuration.x.hirudoki.orderable_days_ahead!)
  end

  def daily_menus(today:)
    menus = DailyMenu.on_sale.served_in(period(today:)).ordered.preload(:orders, bento: { image_attachment: :blob })
    return menus unless Bento.bento_types.key?(bento_type)

    menus.where(bentos: { bento_type: })
  end
end
