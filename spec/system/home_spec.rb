describe 'トップページ', type: :system do
  it 'サイト名が表示されること' do
    visit root_path

    expect(page).to have_css 'h1', text: 'ひるどき'
  end
end
