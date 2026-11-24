class BentosController < ApplicationController
  before_action :authenticate_user!

  def show
    # NOTE: 非販売の弁当は献立一覧に出さないため、URL を直接開いても詳細を見られないよう 404 にしている
    @bento = Bento.on_sale.find(params[:id])
    @reviews = @bento.reviews.order(created_at: :desc, id: :desc)
  end
end
