class Users::RegistrationsController < Devise::RegistrationsController
  # NOTE: 退会は課題の対象外。devise_for を素直な形のまま使うため、ルートは残してここで拒否している。
  #       フラッシュ付きでリダイレクトすると退会機能があるように見えるので、ルートがないときと同じ 404 を返す。
  def destroy
    head :not_found
  end
end
