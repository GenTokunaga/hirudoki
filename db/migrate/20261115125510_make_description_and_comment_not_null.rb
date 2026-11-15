class MakeDescriptionAndCommentNotNull < ActiveRecord::Migration[8.1]
  def change
    change_table :bentos, bulk: true do |t|
      t.change_default :description, from: nil, to: ''
      t.change_null :description, false, ''
    end

    change_table :reviews, bulk: true do |t|
      t.change_default :comment, from: nil, to: ''
      t.change_null :comment, false, ''
    end
  end
end
