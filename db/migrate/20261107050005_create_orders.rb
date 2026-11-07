# 注文。仕様「4. データベース設計 / 注文」に対応する。
# 提供日と弁当は日別献立から辿る。
# 単価・割引単価は注文時点の値を控え、後から弁当の価格や税率が変わっても金額を変えない。
class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user,              null: false, foreign_key: true
      t.references :daily_menu,        null: false, foreign_key: true
      t.integer    :quantity,          null: false
      t.references :delivery_area,     null: false, foreign_key: true
      t.string     :delivery_address,  null: false
      t.integer    :unit_price,        null: false # 注文時点の税抜価格
      t.integer    :discount_per_unit, null: false # 注文時点の 1 個あたり割引額（手動注文は 0）
      t.integer    :total_price,       null: false # 税込の合計金額
      t.string     :status,            null: false, default: "ordered" # ordered / received / canceled
      t.references :subscription,      foreign_key: true # 値があれば定期注文から生成。手動注文は NULL

      t.timestamps
    end

    add_check_constraint :orders, "quantity BETWEEN 1 AND 3", name: "orders_quantity_check"
    add_check_constraint :orders, "unit_price >= 0", name: "orders_unit_price_check"
    add_check_constraint :orders, "discount_per_unit >= 0", name: "orders_discount_per_unit_check"
    add_check_constraint :orders, "total_price >= 0", name: "orders_total_price_check"
    add_check_constraint :orders, "status IN ('ordered', 'received', 'canceled')", name: "orders_status_check"
  end
end
