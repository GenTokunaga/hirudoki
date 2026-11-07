# 評価。仕様「4. データベース設計 / 評価」に対応する。
# 受取済みの注文 1 件につき 1 回だけ投稿できる（order_id を一意にする）。
class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :order,   null: false, foreign_key: true, index: { unique: true }
      t.integer    :rating,  null: false # 1〜5
      t.text       :comment

      t.timestamps
    end

    add_check_constraint :reviews, "rating BETWEEN 1 AND 5", name: "reviews_rating_check"
  end
end
