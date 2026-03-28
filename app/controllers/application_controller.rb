class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: "Payment not found" }, status: :not_found
  end
end
