class Admins::DeliveryAreasController < Admins::ApplicationController
  before_action :set_delivery_area, only: %i[edit update destroy]

  def index
    @delivery_areas = DeliveryArea.ordered
  end

  def new
    @delivery_area = DeliveryArea.new
  end

  def edit; end

  def create
    @delivery_area = DeliveryArea.new(delivery_area_params)
    if @delivery_area.save
      redirect_to admins_delivery_areas_path, notice: "#{@delivery_area.name}を登録しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @delivery_area.update(delivery_area_params)
      redirect_to admins_delivery_areas_path, notice: "#{@delivery_area.name}を更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @delivery_area.destroy
      redirect_to admins_delivery_areas_path, notice: "#{@delivery_area.name}を削除しました。", status: :see_other
    else
      redirect_to admins_delivery_areas_path, alert: @delivery_area.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_delivery_area
    @delivery_area = DeliveryArea.find(params[:id])
  end

  def delivery_area_params
    params.expect(delivery_area: %i[name postal_code active])
  end
end
