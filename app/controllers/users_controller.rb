class UsersController < ApplicationController
  def index
    @pros = User.approved_pros.order(:name)

    if user_signed_in?
      @favorites_by_user_id = current_user.favorites
        .where(favoritable_type: "User", favoritable_id: @pros.map(&:id))
        .index_by(&:favoritable_id)
    else
      @favorites_by_user_id = {}
    end
  end

  def pro_suggestions
    q = params[:q].to_s.strip
    selected_ids = params[:selected_ids].to_s.split(",").map(&:to_i)

    @users =
      if q.blank?
        User.none
      else
        User.approved_pros
            .where("name ILIKE ?", "%#{q}%")
            .where.not(id: selected_ids)
            .order(:name)
            .limit(8)
      end

    render partial: "users/pro_suggestions", locals: { users: @users }
  end
end
