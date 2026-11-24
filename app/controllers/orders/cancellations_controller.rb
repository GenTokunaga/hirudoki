class Orders::CancellationsController < ApplicationController
  before_action :authenticate_user!

  def create
    order = current_user.orders.preload(daily_menu: :bento).find(params[:order_id])
    if order.cancel(now: Time.current)
      redirect_to order_path(order), notice: '注文をキャンセルしました。', status: :see_other
    else
      redirect_to order_path(order), alert: order.errors.full_messages.to_sentence, status: :see_other
    end
  end
end
