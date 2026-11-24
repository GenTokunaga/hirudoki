class Users::RegistrationsController < Devise::RegistrationsController
  # NOTE: routes.rbの複雑性回避のためcontrollerで明示的にユーザー削除(退会)処理を除外
  def destroy
    head :not_found
  end

  protected

  def after_update_path_for(_resource)
    mypage_path
  end
end
