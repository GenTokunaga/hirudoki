describe Review do
  describe '投稿できる注文' do
    it '受取済みの注文には投稿できること' do
      review = build(:review, order: create(:order, :received))

      expect(review).to be_valid
    end

    it '注文済みの注文には投稿できないこと' do
      review = build(:review, order: create(:order))

      expect(review).not_to be_valid
      expect(review.errors[:base]).to include '評価は、受取済みの注文にだけ投稿できます'
    end

    it 'キャンセル済みの注文には投稿できないこと' do
      review = build(:review, order: create(:order, :canceled))

      expect(review).not_to be_valid
      expect(review.errors[:base]).to include '評価は、受取済みの注文にだけ投稿できます'
    end

    it '同じ注文には 2 回目を投稿できないこと' do
      order = create(:order, :received)
      create(:review, order:)
      second_review = build(:review, order:)

      expect(second_review).not_to be_valid
      expect(second_review.errors[:order_id]).to include 'には、すでに評価を投稿しています'
    end
  end

  describe '評価' do
    it '1 なら投稿できること' do
      expect(build(:review, rating: 1)).to be_valid
    end

    it '0 なら投稿できないこと' do
      expect(build(:review, rating: 0)).not_to be_valid
    end

    it '5 なら投稿できること' do
      expect(build(:review, rating: 5)).to be_valid
    end

    it '6 なら投稿できないこと' do
      expect(build(:review, rating: 6)).not_to be_valid
    end
  end
end
