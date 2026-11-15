describe Bento do
  describe '販売フラグ' do
    it '指定しなければ販売中になること' do
      bento = Bento.new

      expect(bento.on_sale).to be true
    end
  end

  describe '画像' do
    it 'PNG 画像は登録できること' do
      bento = build(:bento)
      bento.image.attach(io: file_fixture('bento.png').open, filename: 'bento.png', content_type: 'image/png')

      expect(bento).to be_valid
    end

    it '画像以外のファイルは登録できないこと' do
      bento = build(:bento)
      bento.image.attach(io: file_fixture('bento.txt').open, filename: 'bento.txt', content_type: 'text/plain')

      expect(bento).not_to be_valid
      expect(bento.errors[:image]).to include 'は JPEG・PNG・WebP のいずれかにしてください'
    end

    it '5MB を超える画像は登録できないこと' do
      bento = build(:bento)
      bento.image.attach(io: StringIO.new('a' * (5.megabytes + 1)), filename: 'large.png', content_type: 'image/png')

      expect(bento).not_to be_valid
      expect(bento.errors[:image]).to include 'は 5MB 以下にしてください'
    end
  end

  describe '削除' do
    it '献立から参照されていなければ削除できること' do
      bento = create(:bento)

      expect(bento.destroy).to be_truthy
      expect(Bento.exists?(bento.id)).to be false
    end

    it '献立から参照されている弁当は削除できないこと' do
      bento = create(:bento)
      create(:daily_menu, bento:)

      expect(bento.destroy).to be false
      expect(bento.errors.full_messages).to include '日別献立が存在しているので削除できません'
      expect(Bento.exists?(bento.id)).to be true
    end

    it 'キャンセル済みの注文しかない弁当も削除できないこと' do
      bento = create(:bento)
      create(:order, daily_menu: create(:daily_menu, bento:), status: :canceled)

      expect(bento.destroy).to be false
      expect(Bento.exists?(bento.id)).to be true
    end
  end

  describe '.next_position' do
    it '登録済みの表示順の最大値に 1 を足した値を返すこと' do
      create(:bento, position: 3)
      create(:bento, position: 7)

      expect(Bento.next_position).to eq 8
    end

    it '弁当がなければ 1 を返すこと' do
      expect(Bento.next_position).to eq 1
    end
  end
end
