class DailyMenus::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_daily_menu

  def new
    @order = current_user.build_order(daily_menu: @daily_menu)
  end

  def create
    @order = current_user.orders.build(order_params.merge(daily_menu: @daily_menu))
    if @order.submit(now: Time.current)
      redirect_to order_path(@order), notice: '注文しました。'
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_daily_menu
    @daily_menu = DailyMenu.on_sale.preload(:orders, bento: { image_attachment: :blob }).find(params[:daily_menu_id])
  end

  def order_params
    params.expect(order: %i[quantity delivery_area_id delivery_address])
  end
end
