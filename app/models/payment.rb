class Payment < ApplicationRecord
  enum status: { 
    pending: "pending", 
    processing: "processing", 
    completed: "completed", 
    failed: "failed", 
    cancelled: "cancelled" 
  }

  validates :user_id, :amount, :provider_type, :idempotency_key, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: statuses.keys }
  validates :idempotency_key, uniqueness: true

  scope :by_status, ->(status) { where(status: status) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
end
