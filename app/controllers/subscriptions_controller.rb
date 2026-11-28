class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: %i[edit update]

  def index
    @subscriptions = current_user.subscriptions.ordered.preload(:delivery_area)
  end

  def new
    @subscription = current_user.build_subscription
  end

  def edit; end

  def create
    @subscription = current_user.subscriptions.build(subscription_params)
    if @subscription.save
      redirect_to subscriptions_path, notice: "#{helpers.wday_name(@subscription.wday)}の定期注文を登録しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to subscriptions_path, notice: "#{helpers.wday_name(@subscription.wday)}の定期注文を更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def subscription_params
    params.expect(subscription: %i[wday bento_type quantity delivery_area_id delivery_address active])
  end
end
