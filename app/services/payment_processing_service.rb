class PaymentProcessingService < ApplicationService
  MAX_RETRIES = 3

  def initialize(payment_id)
    @payment_id = payment_id
  end

  def call
    retries ||= 0
    Payment.transaction do
      @payment = Payment.lock.find(@payment_id)

      log_info("Processing payment #{@payment.id}")

      return unless @payment.pending?
      return if @payment.cancelled?
      
      @payment.update!(status: :processing)

      result = simulate_provider

      result[:success] ? mark_completed : handle_failure(result[:error])
    end

  rescue ActiveRecord::Deadlocked
    retries += 1
    log_warn("Deadlock detected, retrying #{retries}")

    retry if retries <= MAX_RETRIES
    raise
  end

  private

  def simulate_provider
    log_info("Simulating #{ @payment.provider_type } payment")

    sleep(0.5)

    rand > 0.15 ?
      { success: true } :
      { success: false, error: "Payment gateway timeout" }
  end

  def mark_completed
    @payment.update!(
      status: :completed,
      processed_at: Time.current
    )
    log_info("Payment #{@payment.id} completed")
  end

  def handle_failure(error_msg)
    if @payment.retry_count < MAX_RETRIES
      @payment.increment!(:retry_count)
      log_warn("Retry #{@payment.retry_count} for payment #{@payment.id}")

      raise StandardError, error_msg # triggers retry
    else
      mark_failed(error_msg)
    end
  end

  def mark_failed(error_msg)
    @payment.update!(
      status: :failed,
      error_code: "PROCESSING_ERROR",
      error_message: error_msg,
      retry_count: @payment.retry_count
    )
    log_warn("Payment #{@payment.id} failed: #{error_msg}")
  end
end
