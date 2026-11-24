class BentosController < ApplicationController
  before_action :authenticate_user!

  def show
    @bento = Bento.on_sale.find(params[:id])
    @reviews = @bento.reviews.order(created_at: :desc, id: :desc)
  end
end
