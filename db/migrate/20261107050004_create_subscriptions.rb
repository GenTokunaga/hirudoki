class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user,             null: false, foreign_key: true
      t.integer    :wday,             null: false
      t.string     :bento_type,       null: false
      t.integer    :quantity,         null: false
      t.references :delivery_area,    null: false, foreign_key: true
      t.string     :delivery_address, null: false
      t.boolean    :active,           null: false, default: true

      t.timestamps
    end

    add_index :subscriptions, %i[user_id wday], unique: true
    add_check_constraint :subscriptions, 'wday BETWEEN 1 AND 5', name: 'subscriptions_wday_check'
    add_check_constraint :subscriptions, "bento_type IN ('japanese', 'western', 'chinese', 'healthy')",
                         name: 'subscriptions_bento_type_check'
    add_check_constraint :subscriptions, 'quantity BETWEEN 1 AND 3', name: 'subscriptions_quantity_check'
  end
end
