require "rails_helper"

RSpec.describe User, type: :model do
  it "必要な項目がそろっていれば有効" do
    expect(build(:user)).to be_valid
  end

  describe "必須項目" do
    %i[name email phone_number password].each do |attribute|
      it "#{attribute} が空なら無効" do
        user = build(:user, attribute => "")

        expect(user).to be_invalid
        expect(user.errors[attribute]).to be_present
      end
    end
  end

  describe "メールアドレス" do
    it "形式が正しくなければ無効" do
      expect(build(:user, email: "not-an-email")).to be_invalid
    end

    it "登録済みのアドレスは大文字・小文字が違っても使えない" do
      create(:user, email: "taro@example.com")

      user = build(:user, email: "TARO@example.com")

      expect(user).to be_invalid
      expect(user.errors[:email]).to be_present
    end

    it "DB でも一意になっている" do
      create(:user, email: "taro@example.com")
      duplicate = build(:user, email: "taro@example.com")

      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "電話番号" do
    %w[09012345678 0312345678 090-1234-5678 03-1234-5678].each do |number|
      it "#{number} は有効" do
        expect(build(:user, phone_number: number)).to be_valid
      end
    end

    %w[090-1234 abc-defg-hijk 090123456789 +81-90-1234-5678].each do |number|
      it "#{number} は無効" do
        expect(build(:user, phone_number: number)).to be_invalid
      end
    end
  end

  describe "パスワード" do
    it "ハッシュ化して保存され、平文は保存されない" do
      user = create(:user, password: "password123")

      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password).not_to eq "password123"
      expect(user.valid_password?("password123")).to be true
    end

    it "6 文字未満は無効" do
      expect(build(:user, password: "12345")).to be_invalid
    end
  end

  it "氏名は 50 文字まで" do
    expect(build(:user, name: "あ" * 50)).to be_valid
    expect(build(:user, name: "あ" * 51)).to be_invalid
  end
end
