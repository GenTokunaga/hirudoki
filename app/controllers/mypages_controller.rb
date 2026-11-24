class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @orders = current_user.orders.joins(:daily_menu).merge(DailyMenu.order(served_on: :desc)).order(id: :desc)
                          .preload(daily_menu: :bento)
  end
end
