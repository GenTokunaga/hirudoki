module ApplicationHelper
  # flash のキーを Bootstrap の alert の色に対応させる。
  # notice（成功）は緑、alert（失敗）は赤。それ以外は情報扱いの青にする。
  def flash_alert_class(type)
    case type.to_s
    when 'notice' then 'alert-success'
    when 'alert' then 'alert-danger'
    else 'alert-info'
    end
  end

  # ナビゲーションのリンク。表示中のページのリンクは強調し、
  # スクリーンリーダー向けに aria-current="page" を付ける。
  def nav_link_to(name, path)
    current = current_page?(path)
    link_to name, path,
            class: ['nav-link', { 'active' => current }],
            aria: { current: (current ? 'page' : nil) }
  end
end
