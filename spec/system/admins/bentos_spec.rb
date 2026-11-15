describe '弁当の管理', type: :system do
  before do
    sign_in create(:admin), scope: :admin
  end

  it '画像付きで登録し、編集して非販売に切り替えられること' do
    visit admins_bentos_path
    click_link '弁当を登録'

    fill_in '弁当名', with: '鮭の塩焼き弁当'
    fill_in '説明', with: '脂ののった鮭を塩焼きにしました。'
    select '和食', from: '弁当タイプ'
    fill_in '価格（税抜）', with: '650'
    attach_file '画像', file_fixture('bento.png')
    click_button '登録する'

    expect(page).to have_content '鮭の塩焼き弁当を登録しました。'
    bento = Bento.find_by!(name: '鮭の塩焼き弁当')
    within "[data-test-id='#{dom_id(bento)}']" do
      expect(page).to have_css "img[alt='鮭の塩焼き弁当']"
      expect(page).to have_content '和食'
      expect(page).to have_content '650円'
      expect(page).to have_content '販売中'
      click_link '編集'
    end

    expect(page).to have_css "a[aria-current='page']", text: '弁当'
    fill_in '価格（税抜）', with: '700'
    uncheck '販売する'
    click_button '更新する'

    expect(page).to have_content '鮭の塩焼き弁当を更新しました。'
    within "[data-test-id='#{dom_id(bento)}']" do
      expect(page).to have_content '700円'
      expect(page).to have_content '非販売'
    end
  end

  it '入力に誤りがあると登録できないこと' do
    visit new_admins_bento_path

    fill_in '価格（税抜）', with: '-1'
    click_button '登録する'

    expect(page).to have_content '弁当名を入力してください'
    expect(page).to have_content '価格（税抜）は0以上の値にしてください'
    expect(page).to have_css "a[aria-current='page']", text: '弁当'
    expect(Bento.count).to eq 0
  end

  it '献立に使われていない弁当は削除できること' do
    bento = create(:bento, name: '唐揚げ弁当')

    visit admins_bentos_path
    within("[data-test-id='#{dom_id(bento)}']") { click_button '削除' }

    expect(page).to have_content '唐揚げ弁当を削除しました。'
    expect(page).to have_no_css "[data-test-id='#{dom_id(bento)}']"
  end

  it '献立に使われている弁当は削除できないこと' do
    bento = create(:bento, name: '唐揚げ弁当')
    create(:daily_menu, bento:)

    visit admins_bentos_path
    within("[data-test-id='#{dom_id(bento)}']") { click_button '削除' }

    expect(page).to have_content '日別献立が存在しているので削除できません'
    expect(page).to have_css "[data-test-id='#{dom_id(bento)}']"
  end
end
