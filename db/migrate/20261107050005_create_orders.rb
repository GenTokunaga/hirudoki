# NOTE: 単価・割引単価は注文時点の値を控える。後から弁当の価格や税率が変わっても、既存の注文の金額を変えないため
class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user,              null: false, foreign_key: true
      t.references :daily_menu,        null: false, foreign_key: true
      t.integer    :quantity,          null: false
      t.references :delivery_area,     null: false, foreign_key: true
      t.string     :delivery_address,  null: false
      t.integer    :unit_price,        null: false
      t.integer    :discount_per_unit, null: false
      t.integer    :total_price,       null: false
      t.string     :status,            null: false, default: 'ordered'
      t.references :subscription,      foreign_key: true

      t.timestamps
    end

    add_check_constraint :orders, 'quantity BETWEEN 1 AND 3', name: 'orders_quantity_check'
    add_check_constraint :orders, 'unit_price >= 0', name: 'orders_unit_price_check'
    add_check_constraint :orders, 'discount_per_unit >= 0', name: 'orders_discount_per_unit_check'
    add_check_constraint :orders, 'total_price >= 0', name: 'orders_total_price_check'
    add_check_constraint :orders, "status IN ('ordered', 'received', 'canceled')", name: 'orders_status_check'
  end
end
