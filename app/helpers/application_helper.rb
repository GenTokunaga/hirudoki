module ApplicationHelper
  def flash_alert_class(type)
    case type.to_s
    when 'notice' then 'alert-success'
    when 'alert' then 'alert-danger'
    else 'alert-info'
    end
  end

  def nav_link_to(name, path)
    current = current_page?(path) || within_section?(path)
    link_to name, path,
            class: ['nav-link', { 'active' => current }],
            aria: { current: (current ? 'page' : nil) }
  end

  private

  def within_section?(path)
    path != root_path && request.path.start_with?("#{path}/")
  end
end
