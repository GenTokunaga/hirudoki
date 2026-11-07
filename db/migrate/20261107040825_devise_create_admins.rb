# frozen_string_literal: true

# 管理者。仕様「4. データベース設計 / 管理者」に対応する。
# 画面からは作成せず、シードデータで用意する。
class DeviseCreateAdmins < ActiveRecord::Migration[8.1]
  def change
    create_table :admins do |t|
      t.string :name,               null: false
      t.string :email,              null: false
      t.string :encrypted_password, null: false

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :admins, :email, unique: true
  end
end
