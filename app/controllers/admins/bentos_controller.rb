class Admins::BentosController < Admins::ApplicationController
  before_action :set_bento, only: %i[edit update destroy]

  def index
    @bentos = Bento.ordered.with_attached_image
  end

  def new
    @bento = Bento.new(position: Bento.next_position)
  end

  def edit; end

  def create
    @bento = Bento.new(bento_params)
    if @bento.save
      redirect_to admins_bentos_path, notice: "#{@bento.name}を登録しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @bento.update(bento_params)
      redirect_to admins_bentos_path, notice: "#{@bento.name}を更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @bento.destroy
      redirect_to admins_bentos_path, notice: "#{@bento.name}を削除しました。", status: :see_other
    else
      redirect_to admins_bentos_path, alert: @bento.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_bento
    @bento = Bento.find(params[:id])
  end

  def bento_params
    params.expect(bento: %i[name description bento_type price on_sale position image])
  end
end
