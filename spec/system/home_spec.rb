require "rails_helper"

RSpec.describe "トップページ", type: :system do
  it "サイト名が表示される" do
    visit root_path

    expect(page).to have_css("h1", text: "ひるどき")
  end
end
