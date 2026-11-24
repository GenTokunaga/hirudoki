class Orders::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order

  def new
    return redirect_to_order_with_reason unless @order.reviewable?

    @review = @order.build_review
  end

  def create
    @review = Review.new(review_params.merge(order: @order))
    if @review.save
      redirect_to order_path(@order), notice: '評価を投稿しました。'
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_order
    @order = current_user.orders.preload(:review, daily_menu: :bento).find(params[:order_id])
  end

  def review_params
    params.expect(review: %i[rating comment])
  end

  def redirect_to_order_with_reason
    reason = @order.received? ? 'この注文には、すでに評価を投稿しています。' : '評価は、受取済みの注文にだけ投稿できます。'
    redirect_to order_path(@order), alert: reason
  end
end
