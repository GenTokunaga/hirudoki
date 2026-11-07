describe '共通レイアウト', type: :system do
  it 'ヘッダーにサイト名とナビゲーションが表示される' do
    visit root_path

    within 'header' do
      expect(page).to have_link 'ひるどき', href: root_path
      expect(page).to have_css "nav[aria-label='メインナビゲーション']"
    end
  end

  it 'スマホ幅用のメニューボタンがある' do
    visit root_path

    expect(page).to have_button 'メニューを開く'
  end

  it 'ページタイトルにサイト名が入る' do
    visit root_path

    expect(page).to have_title 'ひるどき'
  end

  describe 'ナビゲーションの現在地表示' do
    it '表示中のページのリンクに aria-current="page" が付く' do
      visit root_path

      expect(page).to have_css "a[aria-current='page']", text: '献立'
    end
  end
end
