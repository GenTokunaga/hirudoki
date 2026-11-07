require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#flash_alert_class' do
    it 'notice は成功（緑）になる' do
      expect(helper.flash_alert_class(:notice)).to eq 'alert-success'
    end

    it 'alert は失敗（赤）になる' do
      expect(helper.flash_alert_class('alert')).to eq 'alert-danger'
    end

    it 'それ以外は情報（青）になる' do
      expect(helper.flash_alert_class(:info)).to eq 'alert-info'
    end
  end

  describe '#nav_link_to' do
    it '表示中のページのリンクは active と aria-current が付く' do
      allow(helper).to receive(:current_page?).with('/menus').and_return(true)

      html = helper.nav_link_to('献立', '/menus')

      expect(html).to include('class="nav-link active"')
      expect(html).to include('aria-current="page"')
    end

    it 'ほかのページのリンクには付かない' do
      allow(helper).to receive(:current_page?).with('/menus').and_return(false)

      html = helper.nav_link_to('献立', '/menus')

      expect(html).to include('class="nav-link"')
      expect(html).not_to include('aria-current')
    end
  end
end
