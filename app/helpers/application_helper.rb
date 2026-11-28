module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when 'notice' then 'alert-success'
    when 'alert' then 'alert-danger'
    else 'alert-info'
    end
  end

  def nav_link_to(name, path, icon:, current: false)
    current ||= current_page?(path) || within_section?(path)
    link_to path, class: ['nav-link', 'header-nav-item', { 'active' => current }],
                  aria: { current: (current ? 'page' : nil) } do
      header_nav_icon_with_label(name, icon:)
    end
  end

  def header_nav_icon_with_label(name, icon:)
    safe_join([tag.i(class: ['bi', icon], 'aria-hidden': true), tag.span(name, class: 'header-nav-label')])
  end

  # NOTE: simple_form の共通メッセージは「下記の項目を確認してください」なので、入力欄に紐づかない
  #       base のエラー（締切後など）だけのときは出さない
  def field_errors?(record)
    (record.errors.attribute_names - [:base]).any?
  end

  # NOTE: 注文の詳細やアカウント情報の変更は、ネストを避けたり Devise の URL を使ったりしているため
  #       URL がマイページの下にない（docs/decisions.md 参照）。画面上はマイページから開くので、ナビではマイページの中として現在地を表示している
  def mypage_section?
    controller_path.match?(%r{\A(mypages|orders|users/registrations)(/|\z)})
  end

  # NOTE: 生成の実行結果は POST の URL（/new が付かない）で表示するため、パスの前方一致では現在地にならない
  def subscription_order_generation_section?
    controller_path == 'admins/subscription_order_generations'
  end

  private

  def within_section?(path)
    path != root_path && (request.path == path || request.path.start_with?("#{path}/"))
  end
end
