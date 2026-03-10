RailsAdmin.config do |config|
  config.parent_controller = "RailsAdminController"
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

  config.model "Shop" do
    list do
      field :id
      field :name
      field :user
      field :shop_status
      field :address
      field :google_maps_url
      field :contact_email
      field :shop_applied_at
      field :email_verified_at
      field :created_at
    end

    edit do
      field :name
      field :shop_status
      field :address
      field :google_maps_url
      field :contact_email
      field :shop_applied_at
      field :email_verified_at
    end
  end
end
