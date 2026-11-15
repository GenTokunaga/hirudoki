module DailyMenusHelper
  def bento_options_for_daily_menu
    Bento.order(:position, :id).map do |bento|
      label = "#{bento.name}（#{Bento.human_enum_name(:bento_type, bento.bento_type)}）"
      label += ' ※非販売' unless bento.on_sale?
      [label, bento.id]
    end
  end

  def remaining_stock_label(daily_menu)
    remaining_stock = daily_menu.remaining_stock
    remaining_stock.positive? ? "残り #{remaining_stock} 個" : '売り切れ'
  end

  def daily_menu_period_label(period)
    first_day = I18n.l(period.first, format: :with_wday)
    return "#{first_day} の献立" if period.first == period.last

    "#{first_day} 〜 #{I18n.l(period.last, format: :with_wday)} の献立"
  end
end
