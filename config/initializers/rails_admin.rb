RailsAdmin.config do |config|
  config.asset_source = :sprockets

  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  config.authorize_with :cancancan

  config.actions do
    dashboard
    index
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end

  config.model "User" do
    list do
      # scopes [ :pro_applicants ] # 申請者だけに絞る

      field :id
      field :name
      field :email
      field :pro_player_status
      field :pro_sns_url
      field :pro_applied_at
      field :pro_player
    end
  end
end
