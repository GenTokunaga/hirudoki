class CreateBentos < ActiveRecord::Migration[8.1]
  def change
    create_table :bentos do |t|
      t.string  :name, null: false
      t.text    :description
      t.string  :bento_type, null: false
      t.integer :price,      null: false
      t.boolean :on_sale,    null: false, default: true
      t.integer :position,   null: false

      t.timestamps
    end

    add_check_constraint :bentos, "bento_type IN ('japanese', 'western', 'chinese', 'healthy')",
                         name: 'bentos_bento_type_check'
    add_check_constraint :bentos, 'price >= 0', name: 'bentos_price_check'
  end
end
