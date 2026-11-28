class Admins::ApplicationController < ApplicationController
  before_action :authenticate_admin!

  private

  def served_on_param
    ActiveModel::Type::Date.new.cast(params[:served_on]) || Date.current
  end
end
