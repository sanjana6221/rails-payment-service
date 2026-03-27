class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.bigint :user_id, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :provider_type, null: false
      t.string :status, null: false, default: "pending"
      t.string :idempotency_key, null: false
      t.integer :retry_count, default: 0
      t.string :error_code
      t.string :error_message
      t.datetime :processed_at

      t.timestamps
    end

    add_index :payments, :idempotency_key, unique: true
    add_index :payments, :status
    add_index :payments, :provider_type
    add_index :payments, :user_id
    add_index :payments, [:status, :created_at]
  end
end
