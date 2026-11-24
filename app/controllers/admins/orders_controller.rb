class Admins::OrdersController < Admins::ApplicationController
  before_action :set_order, only: %i[show update]

  def index
    @served_on = ActiveModel::Type::Date.new.cast(params[:served_on]) || Date.current
    @orders = Order.joins(:daily_menu).where(daily_menus: { served_on: @served_on })
                   .preload(:user, :delivery_area, daily_menu: :bento).order(:id)
  end

  def show; end

  def update
    if @order.change_status(params.expect(order: [:status])[:status])
      redirect_to admins_order_path(@order), notice: "ステータスを「#{Order.human_enum_name(:status, @order.status)}」に変更しました。"
    else
      redirect_to admins_order_path(@order), alert: @order.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_order
    @order = Order.preload(:user, :delivery_area, daily_menu: :bento).find(params[:id])
  end
end
