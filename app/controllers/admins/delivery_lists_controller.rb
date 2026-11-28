class Admins::DeliveryListsController < Admins::ApplicationController
  def show
    @served_on = served_on_param
    delivery_list = DeliveryList.new(served_on: @served_on)
    @bentos = delivery_list.bentos_with_total_quantity
    @orders = delivery_list.orders
  end
end
