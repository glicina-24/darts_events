class ProApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :reject_if_already_applied, only: %i[new create]

  def new
    @user = current_user
  end

  def create
    @user = current_user

    if @user.update(pro_application_params.merge(pro_player_status: :pending, pro_applied_at: Time.current))
      redirect_to mypage_path, notice: "プロ申請を送信しました。審査をお待ちください。"
    else
      flash.now[:alert] = "申請に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def pro_application_params
    params.require(:user).permit(:pro_sns_url)
  end

  def reject_if_already_applied
    return unless current_user.pending? || current_user.approved?
    redirect_to mypage_path, alert: "すでに申請済みです。"
  end
end
