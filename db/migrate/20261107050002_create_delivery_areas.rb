# 配達エリア。仕様「4. データベース設計 / 配達エリア」に対応する。
class CreateDeliveryAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_areas do |t|
      t.string  :name,        null: false # 例：渋谷区神南一丁目
      t.string  :postal_code, null: false # ハイフンなし 7 桁
      t.boolean :active,      null: false, default: true # false のエリアは選択肢に出さない

      t.timestamps
    end

    add_index :delivery_areas, :postal_code, unique: true
    add_check_constraint :delivery_areas, "postal_code ~ '^[0-9]{7}$'", name: "delivery_areas_postal_code_check"
  end
end
