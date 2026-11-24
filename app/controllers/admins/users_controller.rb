class Admins::UsersController < Admins::ApplicationController
  def index
    @users = User.order(:id)
  end

  def show
    @user = User.find(params[:id])
    @month = DailyMenu.parse_month(params[:month], fallback: Date.current)
    @billing_amount = @user.billing_amount_for(@month)
    @orders = @user.orders_served_in(@month).merge(DailyMenu.order(:served_on)).order(:id).preload(daily_menu: :bento)
  end
end
