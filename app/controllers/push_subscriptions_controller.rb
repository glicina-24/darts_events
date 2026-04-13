class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    subscription = PushSubscription.find_by(endpoint: push_subscription_params[:endpoint])

    if subscription.nil?
      new_subscription = current_user.push_subscriptions.build(push_subscription_params)
      if new_subscription.save
        return render json: { id: new_subscription.id }, status: :created
      end

      return render json: { errors: new_subscription.errors.full_messages }, status: :unprocessable_content
    end

    if subscription.user_id != current_user.id
      return render json: { errors: [ "endpoint is already registered by another user" ] }, status: :conflict
    end

    if subscription.update(push_subscription_params.except(:endpoint))
      render json: { id: subscription.id }, status: :ok
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
