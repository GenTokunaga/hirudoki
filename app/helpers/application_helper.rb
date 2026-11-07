module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when 'notice' then 'alert-success'
    when 'alert' then 'alert-danger'
    else 'alert-info'
    end
  end

  def nav_link_to(name, path)
    current = current_page?(path)
    link_to name, path,
            class: ['nav-link', { 'active' => current }],
            aria: { current: (current ? 'page' : nil) }
  end
end
