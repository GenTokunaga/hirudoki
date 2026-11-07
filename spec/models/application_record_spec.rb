describe ApplicationRecord do
  describe '.human_enum_name' do
    it 'enum の値を ja.yml の表示名に変換すること' do
      expect(Bento.human_enum_name(:bento_type, :healthy)).to eq 'ヘルシー'
      expect(Order.human_enum_name(:status, :canceled)).to eq 'キャンセル済'
    end
  end
end
