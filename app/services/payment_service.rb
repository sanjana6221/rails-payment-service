class PaymentService < ApplicationService
  def initialize(user_id:, amount:, provider_type:, idempotency_key:)
    @user_id = user_id
    @amount = amount
    @provider_type = provider_type
    @idempotency_key = idempotency_key
  end

  def call
    log_info("Creating payment for key #{@idempotency_key}")

    existing = Payment.find_by(idempotency_key: @idempotency_key)

    if existing
      if payload_mismatch?(existing)
        return { status: :conflict, payment: existing, duplicate: false }
      end

      return { status: :ok, payment: existing, duplicate: true }
    end

    payment = create_payment_with_retry

    PaymentProcessorJob.perform_later(payment.id)

    { status: :accepted, payment: payment, duplicate: false }
  end

  private

  def payload_mismatch?(payment)
    payment.user_id != @user_id.to_i ||
    payment.amount.to_d != @amount.to_d ||
    payment.provider_type != @provider_type
  end

  def create_payment_with_retry
    Payment.create!(
      user_id: @user_id,
      amount: @amount,
      provider_type: @provider_type,
      status: :pending,
      retry_count: 0,
      idempotency_key: @idempotency_key
    )
  rescue ActiveRecord::RecordNotUnique
    Payment.find_by!(idempotency_key: @idempotency_key)
  end
end
