class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    subscription = PushSubscription.find_or_initialize_by(endpoint: push_subscription_params[:endpoint])
    subscription.user = current_user
    subscription.assign_attributes(push_subscription_params.except(:endpoint))

    if subscription.save
      status = subscription.previously_new_record? ? :created : :ok
      render json: { id: subscription.id }, status: status
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    endpoint = destroy_endpoint
    return render json: { errors: [ "endpoint is required" ] }, status: :bad_request if endpoint.blank?

    subscription = current_user.push_subscriptions.find_by(endpoint: endpoint)
    return head :no_content unless subscription

    subscription.destroy!
    head :no_content
  end

  private

  def push_subscription_params
    params.require(:push_subscription).permit(
      :endpoint,
      :p256dh,
      :auth,
      :expiration_time,
      :user_agent
    )
  end

  def destroy_endpoint
    params[:endpoint].presence || params.dig(:push_subscription, :endpoint)
  end
end
