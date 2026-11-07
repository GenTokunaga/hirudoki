# 弁当。仕様「4. データベース設計 / 弁当」に対応する。
# 画像（1 枚）は Active Storage（active_storage_attachments）で持つ。
class CreateBentos < ActiveRecord::Migration[8.1]
  def change
    create_table :bentos do |t|
      t.string  :name, null: false
      t.text    :description
      t.string  :bento_type, null: false # japanese / western / chinese / healthy
      t.integer :price,      null: false # 税抜・1 個あたり
      t.boolean :on_sale,    null: false, default: true # false の弁当は利用者側に表示しない
      t.integer :position,   null: false # 表示順

      t.timestamps
    end

    add_check_constraint :bentos, "bento_type IN ('japanese', 'western', 'chinese', 'healthy')",
                         name: 'bentos_bento_type_check'
    add_check_constraint :bentos, 'price >= 0', name: 'bentos_price_check'
  end
end
