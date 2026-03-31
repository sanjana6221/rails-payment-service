# Rails Payment Service

A **Rails 7 API-only application** for handling payment transactions, built with PostgreSQL

---

## Overview

This project implements a **payment processing backend** that handles real-world challenges such as:

* Duplicate requests
* Retry without duplication
* Downstream failure simulation
* Concurrent requests
* Cancellation during processing
* Slow processing (async jobs)

---

## Objective

The system is designed to:

* Accept payment requests via API
* Process them asynchronously
* Ensure no duplicate processing
* Handle failures and retries safely

---

## System Design

### 🔹 High-Level Flow

1. Client sends `POST /payments` request with `Idempotency-Key`
2. System checks for duplicate requests
3. If new:

   * Store payment (`status: pending`)
   * Trigger background job
4. Background job processes payment:

   * Updates status (`processing → completed/failed`)
   * Retries on failure
5. Client can fetch or cancel payment

---

## Architecture

* **Controller Layer** → Handles API requests
* **Service Layer** → Business logic (clean separation)
* **Background Jobs** → Async processing using ActiveJob
* **Database** → Stores payment state & ensures idempotency

---

## Database Design

### Payments Table

| Column          | Purpose              |
| --------------- | -------------------- |
| user_id         | User reference       |
| amount          | Payment amount       |
| provider_type   | Payment source       |
| status          | Lifecycle tracking   |
| idempotency_key | Prevent duplicates   |
| retry_count     | Retry tracking       |
| error_code      | Failure code         |
| error_message   | Failure details      |
| processed_at    | Completion timestamp |

### Indexes

* `UNIQUE(idempotency_key)` → prevents duplicate processing
* `status` → faster job queries
* `user_id` → optimized user queries

---

## Idempotency Handling

* Client sends `Idempotency-Key` in headers
* System ensures:

  * Same key + same payload → returns existing record
  * Same key + different payload → returns **409 Conflict**

## Background Processing

* Uses **ActiveJob**
* Payment processing is asynchronous
* Improves scalability and responsiveness

---

## Retry Mechanism

* Handled via **ActiveJob retry**
* Uses **exponential backoff**

### Logic:

* Retry only for transient failures
* Controlled using `retry_count`
* Stops after max retry attempts

---

## Failure Handling

Failures are persisted with:

* `error_code`
* `error_message`

---

## Cancellation Handling

* API: `POST /payments/:id/cancel`

### Allowed only when:

* `pending`
* `processing`

Prevents invalid state transitions.

---

## API Endpoints

### ➤ Create Payment

```http
POST /payments
Headers:
  Idempotency-Key: <unique_key>
```

#### Responses:

* `202 Accepted` → New request
* `200 OK` → Duplicate request
* `409 Conflict` → Payload mismatch
* `400 Bad Request` → Invalid input

---

### ➤ Get Payment

```http
GET /payments/:id
```

---

### ➤ Cancel Payment

```http
POST /payments/:id/cancel
```

---

## How to Run

### 1. Prerequisites

* Ruby 4.0.2
* PostgreSQL 15+
* Bundler

---

### 2. Install Dependencies

```bash
bundle install
```

---

### 3. Setup Database

```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

---

### 4. Start Rails Server

```bash
bin/rails server -b 0.0.0.0
```

---

### 5. Start Background Jobs

```bash
bundle exec sidekiq
```

---

### 6. Test API

#### Create Payment

```bash
curl -X POST http://localhost:3000/payments \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: abc123" \
  -d '{
    "payment": {
      "user_id": 1,
      "amount": 100,
      "provider_type": "upi"
    }
  }'
```
---

## Future Improvements

* Support multiple payment providers (Stripe, UPI, etc.)
* Add monitoring & metrics
* Add automated test coverage
