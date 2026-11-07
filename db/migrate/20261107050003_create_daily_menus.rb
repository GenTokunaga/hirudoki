# 日別献立。仕様「4. データベース設計 / 日別献立」に対応する。
# 残数のカラムは持たない（提供数上限と注文から算出する）。
#
# 「同じ提供日に同じ弁当タイプは 1 件まで」はアプリ側の検証で表現する。
# 弁当タイプは弁当テーブルにあるため、DB の一意制約で表すには
# 弁当タイプをこのテーブルにも複製する必要があり、二重管理になるため。
class CreateDailyMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_menus do |t|
      t.date       :served_on,   null: false # 提供日
      t.references :bento,       null: false, foreign_key: true
      t.integer    :stock_limit, null: false # 提供数上限（手動注文の受付枠）

      t.timestamps
    end

    add_index :daily_menus, %i[served_on bento_id], unique: true
    add_check_constraint :daily_menus, "stock_limit >= 0", name: "daily_menus_stock_limit_check"
  end
end
