class DailyMenusController < ApplicationController
  def index
    @search = DailyMenuSearch.new(search_params)
    @period = @search.period(today: Date.current)
    @daily_menus_by_date = @search.daily_menus(today: Date.current).group_by(&:served_on)
  end

  private

  def search_params
    params.permit(:served_on, :bento_type)
  end
end
