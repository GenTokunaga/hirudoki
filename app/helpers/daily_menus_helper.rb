module DailyMenusHelper
  def bento_options_for_daily_menu
    Bento.order(:position, :id).map do |bento|
      label = "#{bento.name}（#{Bento.human_enum_name(:bento_type, bento.bento_type)}）"
      label += ' ※非販売' unless bento.on_sale?
      [label, bento.id]
    end
  end
end
