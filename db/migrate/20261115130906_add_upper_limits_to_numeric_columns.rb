class AddUpperLimitsToNumericColumns < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :bentos, 'price >= 0', name: 'bentos_price_check'
    add_check_constraint :bentos, 'price BETWEEN 0 AND 100000', name: 'bentos_price_check'
    add_check_constraint :bentos, 'position BETWEEN 1 AND 9999', name: 'bentos_position_check'

    remove_check_constraint :daily_menus, 'stock_limit >= 0', name: 'daily_menus_stock_limit_check'
    add_check_constraint :daily_menus, 'stock_limit BETWEEN 0 AND 1000', name: 'daily_menus_stock_limit_check'
  end
end
