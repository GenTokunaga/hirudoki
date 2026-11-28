class Admins::SubscriptionOrderGenerationsController < Admins::ApplicationController
  def new
    @generation = SubscriptionOrderGeneration.new(served_on: Date.current)
  end

  def create
    @generation = SubscriptionOrderGeneration.new(params.expect(subscription_order_generation: [:served_on]))
    if @generation.run(now: Time.current)
      @generated_orders = Order.where(id: @generation.generated_orders).preload(:user, daily_menu: :bento).order(:id)
    else
      render :new, status: :unprocessable_content
    end
  end
end
