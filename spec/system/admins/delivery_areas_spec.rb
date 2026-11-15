describe '配達エリアの管理', type: :system do
  before do
    sign_in create(:admin), scope: :admin
  end

  it '登録し、編集して無効に切り替えられること' do
    visit admins_delivery_areas_path
    click_link '配達エリアを登録'

    fill_in 'エリア名', with: '渋谷区神南一丁目'
    fill_in '郵便番号', with: '150-0041'
    click_button '登録する'

    expect(page).to have_content '渋谷区神南一丁目を登録しました。'
    delivery_area = DeliveryArea.find_by!(postal_code: '1500041')
    within "[data-test-id='#{dom_id(delivery_area)}']" do
      expect(page).to have_content '〒150-0041'
      expect(page).to have_content '有効'
      click_link '編集'
    end

    expect(page).to have_css "a[aria-current='page']", text: '配達エリア'
    uncheck '有効にする'
    click_button '更新する'

    expect(page).to have_content '渋谷区神南一丁目を更新しました。'
    within "[data-test-id='#{dom_id(delivery_area)}']" do
      expect(page).to have_content '無効'
    end
  end

  it '郵便番号が 7 桁でないと登録できないこと' do
    visit new_admins_delivery_area_path

    fill_in 'エリア名', with: '渋谷区神南一丁目'
    fill_in '郵便番号', with: '150-004'
    click_button '登録する'

    expect(page).to have_content '郵便番号は不正な値です'
    expect(DeliveryArea.count).to eq 0
  end

  it '使われていないエリアは削除できること' do
    delivery_area = create(:delivery_area, name: '渋谷区神南一丁目')

    visit admins_delivery_areas_path
    within("[data-test-id='#{dom_id(delivery_area)}']") { click_button '削除' }

    expect(page).to have_content '渋谷区神南一丁目を削除しました。'
    expect(page).to have_no_css "[data-test-id='#{dom_id(delivery_area)}']"
  end

  it '注文で使われているエリアは削除できないこと' do
    delivery_area = create(:delivery_area, name: '渋谷区神南一丁目')
    create(:order, delivery_area:)

    visit admins_delivery_areas_path
    within("[data-test-id='#{dom_id(delivery_area)}']") { click_button '削除' }

    expect(page).to have_content '注文が存在しているので削除できません'
    expect(page).to have_css "[data-test-id='#{dom_id(delivery_area)}']"
  end
end
