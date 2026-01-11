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
end
