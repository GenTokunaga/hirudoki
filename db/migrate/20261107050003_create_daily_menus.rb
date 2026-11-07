# NOTE: 「同じ提供日に同じ弁当タイプは 1 件まで」は DB の一意制約にしたかったが、弁当タイプを
#       このテーブルにも複製する必要があり二重管理になるため、アプリ側の検証で表現している
class CreateDailyMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_menus do |t|
      t.date       :served_on,   null: false
      t.references :bento,       null: false, foreign_key: true
      t.integer    :stock_limit, null: false

      t.timestamps
    end

    add_index :daily_menus, %i[served_on bento_id], unique: true
    add_check_constraint :daily_menus, 'stock_limit >= 0', name: 'daily_menus_stock_limit_check'
  end
end
