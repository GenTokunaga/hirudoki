require "rails_helper"

RSpec.describe Review, type: :model do
  it "必要な項目がそろっていれば有効" do
    expect(build(:review)).to be_valid
  end

  it "コメントは空でもよい" do
    expect(build(:review, comment: nil)).to be_valid
  end

  describe "評価" do
    it "1〜5 は有効" do
      (1..5).each { |rating| expect(build(:review, rating: rating)).to be_valid }
    end

    [ 0, 6 ].each do |rating|
      it "#{rating} は無効で、DB でも弾かれる" do
        review = build(:review, rating: rating)

        expect(review).to be_invalid
        expect_db_to_reject(review)
      end
    end
  end

  it "1つの注文につき1件まで（DB でも弾かれる）" do
    review = create(:review)
    duplicate = build(:review, order: review.order)

    expect(duplicate).to be_invalid
    expect_db_to_reject(duplicate, ActiveRecord::RecordNotUnique)
  end
end
