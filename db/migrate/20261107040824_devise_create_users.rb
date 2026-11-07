# frozen_string_literal: true

# 利用者。仕様「4. データベース設計 / 利用者」に対応する。
# パスワード再設定（Recoverable）はメール送信が必要で、通知全般が対象外のため使わない。
class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name,               null: false
      t.string :email,              null: false
      t.string :encrypted_password, null: false
      t.string :phone_number,       null: false

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
