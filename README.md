# Rails Payment Service

A Rails 8 API-only application for handling payment transactions, built with PostgreSQL.

## Prerequisites

- Ruby 4.0.2
- PostgreSQL 15+
- Bundler

## Local Setup

### 1. Install Ruby 4.0.2

**Option A: Using rbenv (Recommended)**
```bash
# Install rbenv and ruby-build
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Add to ~/.bashrc or ~/.zshrc:
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install Ruby
rbenv install 4.0.2
rbenv local 4.0.2
```

**Option B: Using snapcraft**
```bash
snap install ruby --channel=4.0
```

### 2. Start PostgreSQL Database

**Option A: Using Docker Compose (Recommended)**
```bash
docker compose up -d
```

**Option B: Local PostgreSQL Installation**
```bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

Create database user:
```bash
createuser -P postgres  # Set password to "password"
```

### 3. Install Dependencies
```bash
bundle install
```

### 4. Setup Database
```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

### 5. Start Rails Server
```bash
bin/rails server -b 0.0.0.0
```

The API will be available at: `http://localhost:3000`

## Database Configuration

The app uses PostgreSQL with the following credentials (in development):
- Username: `postgres`
- Password: `password`
- Host: `localhost`
- Database: `rails_payment_service_development`

See `config/database.yml` for all environment configurations.

## Running Tests
```bash
bundle exec rails test
```

## Deployment

This application is configured for deployment with [Kamal](https://kamal-deploy.org).

See `config/deploy.yml` for deployment configuration.
