class OrdersController < ApplicationController
  before_action :authenticate_user!

  def show
    @order = current_user.orders.preload(:delivery_area, daily_menu: :bento).find(params[:id])
  end
end
