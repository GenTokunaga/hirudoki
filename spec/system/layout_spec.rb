require 'rails_helper'

RSpec.describe '共通レイアウト', type: :system do
  it 'ヘッダーにサイト名とナビゲーションが表示される' do
    visit root_path

    within 'header' do
      expect(page).to have_link 'ひるどき', href: root_path
      expect(page).to have_css "nav[aria-label='メインナビゲーション']"
    end
  end

  it '表示中のページのナビゲーションが強調される' do
    visit root_path

    expect(page).to have_css "a.nav-link.active[aria-current='page']", text: '献立'
  end

  it 'スマホ幅用のメニューボタンがある' do
    visit root_path

    expect(page).to have_css "button.navbar-toggler[aria-label='メニューを開く'][aria-controls='global-nav']"
  end

  it 'ページタイトルにサイト名が入る' do
    visit root_path

    expect(page).to have_title 'ひるどき'
  end
end
