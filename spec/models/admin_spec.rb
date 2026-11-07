require 'rails_helper'

RSpec.describe Admin, type: :model do
  it '必要な項目がそろっていれば有効' do
    expect(build(:admin)).to be_valid
  end

  %i[name email password].each do |attribute|
    it "#{attribute} が空なら無効" do
      expect(build(:admin, attribute => '')).not_to be_valid
    end
  end

  it 'メールアドレスは一意' do
    create(:admin, email: 'admin@example.com')

    expect(build(:admin, email: 'ADMIN@example.com')).not_to be_valid
  end

  it 'パスワードはハッシュ化して保存される' do
    admin = create(:admin, password: 'password123')

    expect(admin.encrypted_password).not_to eq 'password123'
    expect(admin.valid_password?('password123')).to be true
  end

  it '画面から登録する機能（registerable）を持たない' do
    expect(Admin.devise_modules).not_to include(:registerable)
  end
end
