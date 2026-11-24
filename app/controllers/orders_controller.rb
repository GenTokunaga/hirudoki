class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order

  def show; end

  def edit
    return if @order.changeable_at?(Time.current)

    redirect_to order_path(@order), alert: helpers.order_unchangeable_reason(@order)
  end

  def update
    if @order.change_quantity(params.expect(order: [:quantity])[:quantity], now: Time.current)
      redirect_to order_path(@order), notice: '個数を変更しました。'
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_order
    @order = current_user.orders.preload(:delivery_area, daily_menu: :bento).find(params[:id])
  end
end
