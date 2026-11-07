class CreateDeliveryAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_areas do |t|
      t.string  :name,        null: false
      t.string  :postal_code, null: false
      t.boolean :active,      null: false, default: true

      t.timestamps
    end

    add_index :delivery_areas, :postal_code, unique: true
    add_check_constraint :delivery_areas, "postal_code ~ '^[0-9]{7}$'", name: 'delivery_areas_postal_code_check'
  end
end
