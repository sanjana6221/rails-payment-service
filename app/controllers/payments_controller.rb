  class PaymentsController < ApplicationController
    include LoggerHelper
    before_action :find_payment, only: [:show, :cancel]

    # POST /payments
    def create
      idempotency_key = request.headers["Idempotency-Key"]
      raise ActionController::ParameterMissing, "Idempotency-Key missing" if idempotency_key.blank?

      result = PaymentService.call(
        payment_params.to_h.merge(idempotency_key: idempotency_key)
      )

      render json: {
        payment: result[:payment],
        duplicate: result[:duplicate],
      }, status: result[:status] || :internal_server_error

    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request

    rescue => e
      log_error(e.message)
      render json: { error: e.message }, status: :internal_server_error
    end

    # GET /payments/:id
    def show
      log_info("Fetched payment #{@payment.id}")
      render json: @payment
    end

    # POST /payments/:id/cancel
    def cancel
      if @payment.pending? || @payment.processing?
        @payment.update!(status: :cancelled)
        log_info("Cancelled payment #{@payment.id}")
        render json: { message: "Payment cancelled" }
      else
        log_warn("Cannot cancel payment #{@payment.id} with status #{@payment.status}")
        render json: { error: "Cannot cancel payment in status #{@payment.status}" }, status: :unprocessable_entity
      end
    end

    private

    def find_payment
      @payment = Payment.find(params[:id])
    end

    def payment_params
      params.require(:payment).permit(:user_id, :amount, :provider_type)
    end
  end
