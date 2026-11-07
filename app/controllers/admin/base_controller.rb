# 管理画面のコントローラーはすべてこれを継承する。
# 管理者としてログインしていなければ、管理者のログイン画面へ送る。
# （利用者としてログインしていても、管理者とは別のセッションなので入れない）
class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!
end
