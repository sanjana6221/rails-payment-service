class PaymentProcessorJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 4

  def perform(payment_id)
    PaymentProcessingService.call(payment_id)
  end
end
