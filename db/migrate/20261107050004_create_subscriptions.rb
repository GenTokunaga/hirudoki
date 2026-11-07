# 定期注文設定。仕様「4. データベース設計 / 定期注文設定」に対応する。
# 個別の弁当ではなく弁当タイプを指し、実際の弁当は生成時にその日の献立から決まる。
# 削除機能は作らず、使わなくなった設定は active を false にする。
class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user,             null: false, foreign_key: true
      t.integer    :wday,             null: false # 1=月 〜 5=金（Date#wday と同じ番号）
      t.string     :bento_type,       null: false
      t.integer    :quantity,         null: false
      t.references :delivery_area,    null: false, foreign_key: true
      t.string     :delivery_address, null: false
      t.boolean    :active,           null: false, default: true

      t.timestamps
    end

    # 1 人につき 1 曜日 1 件まで
    add_index :subscriptions, %i[user_id wday], unique: true
    add_check_constraint :subscriptions, "wday BETWEEN 1 AND 5", name: "subscriptions_wday_check"
    add_check_constraint :subscriptions, "bento_type IN ('japanese', 'western', 'chinese', 'healthy')",
                         name: "subscriptions_bento_type_check"
    add_check_constraint :subscriptions, "quantity BETWEEN 1 AND 3", name: "subscriptions_quantity_check"
  end
end
