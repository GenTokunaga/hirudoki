class Admins::DailyMenusController < Admins::ApplicationController
  before_action :set_daily_menu, only: %i[edit update destroy]

  def index
    @month = selected_month
    @daily_menus = DailyMenu.served_in(@month.all_month)
                            .joins(:bento)
                            .order(:served_on, 'bentos.position', :id)
                            .preload(:bento, :orders)
  end

  def new
    @daily_menu = DailyMenu.new(served_on: params[:served_on])
  end

  def edit; end

  def create
    @daily_menu = DailyMenu.new(daily_menu_params)
    if @daily_menu.save
      redirect_to admins_daily_menus_path(month: month_param(@daily_menu)), notice: "#{menu_label(@daily_menu)}の献立を登録しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @daily_menu.update(daily_menu_params)
      redirect_to admins_daily_menus_path(month: month_param(@daily_menu)), notice: "#{menu_label(@daily_menu)}の献立を更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @daily_menu.destroy
      redirect_to admins_daily_menus_path(month: month_param(@daily_menu)),
                  notice: "#{menu_label(@daily_menu)}の献立を削除しました。", status: :see_other
    else
      redirect_to admins_daily_menus_path(month: month_param(@daily_menu)),
                  alert: @daily_menu.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_daily_menu
    @daily_menu = DailyMenu.find(params[:id])
  end

  def daily_menu_params
    params.expect(daily_menu: %i[served_on bento_id stock_limit])
  end

  def selected_month
    Date.strptime(params[:month].to_s, '%Y-%m')
  rescue Date::Error
    Date.current.beginning_of_month
  end

  def month_param(daily_menu)
    daily_menu.served_on.strftime('%Y-%m')
  end

  def menu_label(daily_menu)
    "#{I18n.l(daily_menu.served_on)} #{daily_menu.bento.name}"
  end
end
