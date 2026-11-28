describe Subscription do
  describe '曜日' do
    it '月曜（1）から金曜（5）までは登録できること' do
      expect(build(:subscription, wday: 1)).to be_valid
      expect(build(:subscription, wday: 5)).to be_valid
    end

    it '日曜（0）と土曜（6）は登録できないこと' do
      expect(build(:subscription, wday: 0)).not_to be_valid
      expect(build(:subscription, wday: 6)).not_to be_valid
    end

    it '同じ利用者が同じ曜日の設定を 2 件登録できないこと' do
      user = create(:user)
      create(:subscription, user:, wday: 3)
      subscription = build(:subscription, user:, wday: 3)

      expect(subscription).not_to be_valid
      expect(subscription.errors[:wday]).to include 'の定期注文設定はすでに登録されています。登録済みの設定を編集してください'
    end

    it '別の利用者なら同じ曜日の設定を登録できること' do
      create(:subscription, wday: 3)

      expect(build(:subscription, wday: 3)).to be_valid
    end
  end

  describe '個数' do
    it '1 個から 3 個までは登録できること' do
      expect(build(:subscription, quantity: 1)).to be_valid
      expect(build(:subscription, quantity: 3)).to be_valid
    end

    it '0 個と 4 個は登録できないこと' do
      expect(build(:subscription, quantity: 0)).not_to be_valid
      expect(build(:subscription, quantity: 4)).not_to be_valid
    end
  end

  describe '配達エリア' do
    it '無効なエリアは選べないこと' do
      subscription = build(:subscription, delivery_area: create(:delivery_area, :inactive))

      expect(subscription).not_to be_valid
      expect(subscription.errors[:delivery_area]).to include 'は現在配達を受け付けていません'
    end

    it '登録後にエリアが無効になっても、エリアを変えなければ他の項目を更新できること' do
      delivery_area = create(:delivery_area)
      subscription = create(:subscription, delivery_area:, quantity: 1)
      delivery_area.update!(active: false)

      expect(subscription.update(quantity: 2)).to be true
    end
  end
end
