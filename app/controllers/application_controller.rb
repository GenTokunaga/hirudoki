class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :admin_area?

  def admin_area?
    controller_path.start_with?('admins/') || (devise_controller? && resource_name == :admin)
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name phone_number])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name phone_number])
  end

  def after_sign_in_path_for(resource)
    resource.is_a?(Admin) ? admins_root_path : stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(scope)
    scope == :admin ? new_admin_session_path : root_path
  end
end
