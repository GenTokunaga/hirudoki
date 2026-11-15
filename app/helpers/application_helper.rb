module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when 'notice' then 'alert-success'
    when 'alert' then 'alert-danger'
    else 'alert-info'
    end
  end

  def nav_link_to(name, path, icon:)
    current = current_page?(path) || within_section?(path)
    link_to path, class: ['nav-link', 'header-nav-item', { 'active' => current }],
                  aria: { current: (current ? 'page' : nil) } do
      header_nav_icon_with_label(name, icon:)
    end
  end

  def header_nav_icon_with_label(name, icon:)
    safe_join([tag.i(class: ['bi', icon], 'aria-hidden': true), tag.span(name, class: 'header-nav-label')])
  end

  def account_settings_page?(settings_path)
    settings_path.present? && current_page?(settings_path)
  end

  private

  def within_section?(path)
    path != root_path && (request.path == path || request.path.start_with?("#{path}/"))
  end
end
