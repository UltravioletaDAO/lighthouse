# TimescaleDB Implementation Guide for Lighthouse

**Status:** Implementation Ready
**Date:** October 29, 2025
**Prerequisites:** Read `DATABASE-ARCHITECTURE-ANALYSIS.md` first

---

## Quick Start (5 Minutes)

### Local Development Setup

```bash
# 1. Start TimescaleDB via Docker
cd lighthouse
docker-compose up -d postgres

# 2. Connect and verify
docker exec -it lighthouse-postgres psql -U postgres -d lighthouse

# 3. Check TimescaleDB is installed
SELECT extversion FROM pg_extension WHERE extname = 'timescaledb';
# Should show: 2.13.0 or higher

# 4. Run migrations
cd backend
cargo install sqlx-cli
export DATABASE_URL="postgresql://postgres:lighthouse_dev@localhost:5432/lighthouse"
sqlx migrate run

# 5. Verify schema
psql $DATABASE_URL -c "\dt"
# Should show: subscriptions, check_history, alert_channels, etc.
```

---

## Schema Design

### Core Tables (Standard PostgreSQL)

**File:** `backend/migrations/001_init.sql`

```sql
-- ============================================================================
-- Users & Wallets
-- ============================================================================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_address VARCHAR(42) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ DEFAULT NOW(),
  settings JSONB DEFAULT '{}',

  CONSTRAINT wallet_address_format CHECK (wallet_address ~ '^0x[a-fA-F0-9]{40}$')
);

CREATE INDEX idx_users_wallet ON users(wallet_address);

-- ============================================================================
-- Subscriptions
-- ============================================================================

CREATE TYPE subscription_tier AS ENUM ('free', 'basic', 'standard', 'pro', 'enterprise');
CREATE TYPE monitor_type AS ENUM ('http', 'websocket', 'balance', 'canary', 'graphql');
CREATE TYPE subscription_status AS ENUM ('pending', 'active', 'paused', 'expired', 'cancelled');

CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Monitor configuration
  target_type monitor_type NOT NULL,
  target_config JSONB NOT NULL,  -- Flexible: HTTP URL, WebSocket endpoint, blockchain address, etc.

  -- Subscription details
  tier subscription_tier NOT NULL DEFAULT 'free',
  check_interval_seconds INTEGER NOT NULL DEFAULT 900,  -- 15 minutes
  status subscription_status NOT NULL DEFAULT 'pending',

  -- Payment tracking
  payment_tx_hash VARCHAR(66),  -- 0x + 64 hex chars
  payment_chain VARCHAR(20),    -- 'avalanche_fuji', 'base_sepolia', etc.
  payment_amount_usdc BIGINT,   -- USDC amount in smallest unit (6 decimals)

  -- Lifecycle
  created_at TIMESTAMPTZ DEFAULT NOW(),
  activated_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,

  -- Metadata
  metadata JSONB DEFAULT '{}',

  CONSTRAINT check_interval_valid CHECK (check_interval_seconds >= 60),
  CONSTRAINT payment_tx_format CHECK (payment_tx_hash IS NULL OR payment_tx_hash ~ '^0x[a-fA-F0-9]{64}$')
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status) WHERE status = 'active';
CREATE INDEX idx_subscriptions_expires_at ON subscriptions(expires_at) WHERE status = 'active';

-- ============================================================================
-- Alert Channels
-- ============================================================================

CREATE TYPE alert_channel_type AS ENUM ('discord', 'telegram', 'email', 'slack', 'webhook', 'sms');

CREATE TABLE alert_channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,

  channel_type alert_channel_type NOT NULL,
  channel_config JSONB NOT NULL,  -- Discord webhook URL, Telegram chat_id, etc.

  -- Alert preferences
  enabled BOOLEAN DEFAULT TRUE,
  min_severity VARCHAR(20) DEFAULT 'warning',  -- 'info', 'warning', 'critical'

  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_used_at TIMESTAMPTZ,

  -- Metadata (e.g., language preference)
  metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_alert_channels_subscription ON alert_channels(subscription_id);

-- ============================================================================
-- Time-Series Tables (Will be converted to hypertables)
-- ============================================================================

CREATE TYPE check_status AS ENUM ('success', 'failure', 'timeout', 'error');

CREATE TABLE check_history (
  time TIMESTAMPTZ NOT NULL,
  subscription_id UUID NOT NULL,

  -- Check result
  status check_status NOT NULL,
  http_status SMALLINT,
  latency_ms INTEGER,

  -- Error details (NULL if success)
  error_message TEXT,
  error_code VARCHAR(50),

  -- Alert tracking
  alert_triggered BOOLEAN DEFAULT FALSE,
  alert_sent_at TIMESTAMPTZ,

  -- Detailed timing (optional)
  timings JSONB,  -- {dns_ms, tcp_ms, tls_ms, ttfb_ms}

  -- Response metadata (truncated, for debugging)
  response_snippet TEXT,  -- First 1KB of response body

  PRIMARY KEY (subscription_id, time)
);

CREATE INDEX idx_check_history_time ON check_history(time DESC);
CREATE INDEX idx_check_history_status ON check_history(status);

-- ============================================================================
-- Alert History (Time-Series)
-- ============================================================================

CREATE TYPE alert_type AS ENUM ('downtime', 'recovery', 'high_latency', 'low_balance', 'certificate_expiry');
CREATE TYPE alert_severity AS ENUM ('info', 'warning', 'critical');

CREATE TABLE alert_history (
  time TIMESTAMPTZ NOT NULL,
  subscription_id UUID NOT NULL,
  alert_channel_id UUID REFERENCES alert_channels(id) ON DELETE SET NULL,

  alert_type alert_type NOT NULL,
  severity alert_severity NOT NULL,

  -- Alert content
  title TEXT NOT NULL,
  message TEXT NOT NULL,

  -- Delivery status
  sent BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMPTZ,
  failed_reason TEXT,

  -- Related check
  related_check_time TIMESTAMPTZ,

  PRIMARY KEY (subscription_id, time)
);

CREATE INDEX idx_alert_history_time ON alert_history(time DESC);
CREATE INDEX idx_alert_history_type ON alert_history(alert_type);

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON TABLE subscriptions IS 'User monitoring subscriptions (relational data)';
COMMENT ON TABLE check_history IS 'Health check results (time-series data, will be hypertable)';
COMMENT ON TABLE alert_history IS 'Alert delivery log (time-series data, will be hypertable)';

COMMENT ON COLUMN subscriptions.target_config IS 'JSONB config: {url, valid_status_codes, max_latency_ms, ...}';
COMMENT ON COLUMN alert_channels.channel_config IS 'JSONB config: {webhook_url, chat_id, email, ...}';
```

### Convert to Hypertables

**File:** `backend/migrations/002_timescaledb_setup.sql`

```sql
-- ============================================================================
-- Convert to TimescaleDB Hypertables
-- ============================================================================

-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Convert check_history to hypertable
SELECT create_hypertable(
  'check_history',
  'time',
  chunk_time_interval => INTERVAL '1 day',
  if_not_exists => TRUE
);

-- Convert alert_history to hypertable
SELECT create_hypertable(
  'alert_history',
  'time',
  chunk_time_interval => INTERVAL '7 days',
  if_not_exists => TRUE
);

-- ============================================================================
-- Compression Policies (10x storage savings)
-- ============================================================================

-- Compress check_history after 7 days
ALTER TABLE check_history SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'subscription_id',
  timescaledb.compress_orderby = 'time DESC'
);

SELECT add_compression_policy('check_history', INTERVAL '7 days');

-- Compress alert_history after 30 days
ALTER TABLE alert_history SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'subscription_id',
  timescaledb.compress_orderby = 'time DESC'
);

SELECT add_compression_policy('alert_history', INTERVAL '30 days');

-- ============================================================================
-- Retention Policies (Auto-delete old data)
-- ============================================================================

-- Delete check_history older than 90 days
SELECT add_retention_policy('check_history', INTERVAL '90 days');

-- Delete alert_history older than 1 year
SELECT add_retention_policy('alert_history', INTERVAL '1 year');

-- ============================================================================
-- Continuous Aggregates (Pre-computed metrics)
-- ============================================================================

-- Hourly metrics (for recent dashboards)
CREATE MATERIALIZED VIEW hourly_metrics
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 hour', time) AS hour,
  subscription_id,

  -- Uptime calculation
  COUNT(*) AS total_checks,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) AS successful_checks,
  (SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END)::FLOAT / COUNT(*)) AS uptime_ratio,

  -- Latency statistics
  AVG(latency_ms) AS avg_latency_ms,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY latency_ms) AS p50_latency_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) AS p95_latency_ms,
  PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY latency_ms) AS p99_latency_ms,
  MIN(latency_ms) AS min_latency_ms,
  MAX(latency_ms) AS max_latency_ms,

  -- Error breakdown
  SUM(CASE WHEN status = 'failure' THEN 1 ELSE 0 END) AS failures,
  SUM(CASE WHEN status = 'timeout' THEN 1 ELSE 0 END) AS timeouts,
  SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) AS errors,

  -- Alert tracking
  SUM(CASE WHEN alert_triggered THEN 1 ELSE 0 END) AS alerts_triggered

FROM check_history
GROUP BY hour, subscription_id;

-- Refresh policy: Update hourly metrics every 30 minutes
SELECT add_continuous_aggregate_policy('hourly_metrics',
  start_offset => INTERVAL '2 hours',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '30 minutes'
);

-- Daily metrics (for historical analysis)
CREATE MATERIALIZED VIEW daily_metrics
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', time) AS day,
  subscription_id,

  COUNT(*) AS total_checks,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) AS successful_checks,
  (SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END)::FLOAT / COUNT(*)) AS uptime_ratio,

  AVG(latency_ms) AS avg_latency_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) AS p95_latency_ms,
  MIN(latency_ms) AS min_latency_ms,
  MAX(latency_ms) AS max_latency_ms,

  SUM(CASE WHEN status = 'failure' THEN 1 ELSE 0 END) AS failures,
  SUM(CASE WHEN status = 'timeout' THEN 1 ELSE 0 END) AS timeouts,
  SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) AS errors,
  SUM(CASE WHEN alert_triggered THEN 1 ELSE 0 END) AS alerts_triggered

FROM check_history
GROUP BY day, subscription_id;

-- Refresh policy: Update daily metrics once per day
SELECT add_continuous_aggregate_policy('daily_metrics',
  start_offset => INTERVAL '3 days',
  end_offset => INTERVAL '1 day',
  schedule_interval => INTERVAL '1 day'
);

-- ============================================================================
-- Indexes for Common Queries
-- ============================================================================

-- Fast lookups for dashboard API
CREATE INDEX idx_hourly_metrics_subscription_hour ON hourly_metrics(subscription_id, hour DESC);
CREATE INDEX idx_daily_metrics_subscription_day ON daily_metrics(subscription_id, day DESC);

-- ============================================================================
-- Verify Setup
-- ============================================================================

-- Show hypertables
SELECT hypertable_name, hypertable_schema
FROM timescaledb_information.hypertables;

-- Show compression policies
SELECT hypertable_name, schedule_interval, compress_after
FROM timescaledb_information.jobs
WHERE proc_name = 'policy_compression';

-- Show retention policies
SELECT hypertable_name, schedule_interval, drop_after
FROM timescaledb_information.jobs
WHERE proc_name = 'policy_retention';

-- Show continuous aggregates
SELECT view_name, materialized_only
FROM timescaledb_information.continuous_aggregates;
```

---

## Rust Integration

### Cargo.toml

```toml
[package]
name = "lighthouse-backend"
version = "0.1.0"
edition = "2021"

[dependencies]
# Async runtime
tokio = { version = "1.35", features = ["full"] }

# Database (TimescaleDB = PostgreSQL)
sqlx = { version = "0.7", features = [
    "postgres",
    "runtime-tokio-rustls",
    "uuid",
    "chrono",
    "json",
    "macros"
] }

# Serialization
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# UUIDs
uuid = { version = "1.6", features = ["v4", "serde"] }

# Timestamps
chrono = { version = "0.4", features = ["serde"] }

# Error handling
anyhow = "1.0"
thiserror = "1.0"

# Logging
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

[build-dependencies]
# Compile-time query verification
sqlx = { version = "0.7", features = ["postgres", "macros", "offline"] }
```

### Database Module

**File:** `backend/src/database/mod.rs`

```rust
use sqlx::{PgPool, postgres::PgPoolOptions};
use anyhow::Result;

pub mod subscriptions;
pub mod checks;
pub mod alerts;
pub mod metrics;

#[derive(Clone)]
pub struct Database {
    pool: PgPool,
}

impl Database {
    pub async fn new(database_url: &str) -> Result<Self> {
        let pool = PgPoolOptions::new()
            .max_connections(20)
            .min_connections(5)
            .acquire_timeout(std::time::Duration::from_secs(5))
            .idle_timeout(std::time::Duration::from_secs(600))
            .connect(database_url)
            .await?;

        // Verify TimescaleDB is available
        let version: String = sqlx::query_scalar("SELECT extversion FROM pg_extension WHERE extname = 'timescaledb'")
            .fetch_one(&pool)
            .await?;

        tracing::info!("Connected to PostgreSQL with TimescaleDB {}", version);

        Ok(Database { pool })
    }

    pub fn pool(&self) -> &PgPool {
        &self.pool
    }

    /// Health check query
    pub async fn health(&self) -> Result<()> {
        sqlx::query("SELECT 1")
            .execute(&self.pool)
            .await?;
        Ok(())
    }
}
```

### Insert Check Results

**File:** `backend/src/database/checks.rs`

```rust
use sqlx::PgPool;
use uuid::Uuid;
use chrono::{DateTime, Utc};
use anyhow::Result;

#[derive(Debug, Clone)]
pub enum CheckStatus {
    Success,
    Failure,
    Timeout,
    Error,
}

impl CheckStatus {
    pub fn as_str(&self) -> &str {
        match self {
            Self::Success => "success",
            Self::Failure => "failure",
            Self::Timeout => "timeout",
            Self::Error => "error",
        }
    }
}

pub struct CheckResult {
    pub subscription_id: Uuid,
    pub status: CheckStatus,
    pub http_status: Option<i16>,
    pub latency_ms: i32,
    pub error_message: Option<String>,
    pub alert_triggered: bool,
}

/// Insert check result into hypertable (time-series optimized)
pub async fn insert_check_result(
    pool: &PgPool,
    result: CheckResult,
) -> Result<()> {
    sqlx::query!(
        r#"
        INSERT INTO check_history (
            time, subscription_id, status, http_status, latency_ms,
            error_message, alert_triggered
        )
        VALUES (NOW(), $1, $2::check_status, $3, $4, $5, $6)
        "#,
        result.subscription_id,
        result.status.as_str(),
        result.http_status,
        result.latency_ms,
        result.error_message,
        result.alert_triggered
    )
    .execute(pool)
    .await?;

    Ok(())
}

/// Get recent check history for a subscription
pub async fn get_recent_checks(
    pool: &PgPool,
    subscription_id: Uuid,
    limit: i64,
) -> Result<Vec<CheckHistoryRow>> {
    let rows = sqlx::query_as!(
        CheckHistoryRow,
        r#"
        SELECT
            time,
            subscription_id,
            status AS "status: _",
            http_status,
            latency_ms,
            error_message,
            alert_triggered
        FROM check_history
        WHERE subscription_id = $1
        ORDER BY time DESC
        LIMIT $2
        "#,
        subscription_id,
        limit
    )
    .fetch_all(pool)
    .await?;

    Ok(rows)
}

#[derive(Debug, sqlx::FromRow)]
pub struct CheckHistoryRow {
    pub time: DateTime<Utc>,
    pub subscription_id: Uuid,
    pub status: String,
    pub http_status: Option<i16>,
    pub latency_ms: i32,
    pub error_message: Option<String>,
    pub alert_triggered: bool,
}
```

### Query Continuous Aggregates

**File:** `backend/src/database/metrics.rs`

```rust
use sqlx::PgPool;
use uuid::Uuid;
use chrono::{DateTime, Utc};
use anyhow::Result;
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct HourlyMetric {
    pub hour: DateTime<Utc>,
    pub subscription_id: Uuid,
    pub total_checks: i64,
    pub successful_checks: i64,
    pub uptime_ratio: f64,
    pub avg_latency_ms: f64,
    pub p50_latency_ms: f64,
    pub p95_latency_ms: f64,
    pub p99_latency_ms: f64,
    pub min_latency_ms: i32,
    pub max_latency_ms: i32,
    pub failures: i64,
    pub timeouts: i64,
    pub errors: i64,
    pub alerts_triggered: i64,
}

/// Get hourly metrics for dashboard (FAST - queries pre-computed data)
pub async fn get_hourly_metrics(
    pool: &PgPool,
    subscription_id: Uuid,
    hours: i32,
) -> Result<Vec<HourlyMetric>> {
    let metrics = sqlx::query_as!(
        HourlyMetric,
        r#"
        SELECT
            hour,
            subscription_id,
            total_checks,
            successful_checks,
            uptime_ratio,
            avg_latency_ms,
            p50_latency_ms,
            p95_latency_ms,
            p99_latency_ms,
            min_latency_ms,
            max_latency_ms,
            failures,
            timeouts,
            errors,
            alerts_triggered
        FROM hourly_metrics
        WHERE subscription_id = $1
          AND hour >= NOW() - INTERVAL '1 hour' * $2
        ORDER BY hour DESC
        "#,
        subscription_id,
        hours
    )
    .fetch_all(pool)
    .await?;

    Ok(metrics)
}

#[derive(Debug, Serialize, Deserialize, sqlx::FromRow)]
pub struct DailyMetric {
    pub day: DateTime<Utc>,
    pub subscription_id: Uuid,
    pub total_checks: i64,
    pub successful_checks: i64,
    pub uptime_ratio: f64,
    pub avg_latency_ms: f64,
    pub p95_latency_ms: f64,
    pub min_latency_ms: i32,
    pub max_latency_ms: i32,
    pub failures: i64,
    pub timeouts: i64,
    pub errors: i64,
    pub alerts_triggered: i64,
}

/// Get daily metrics for historical reports
pub async fn get_daily_metrics(
    pool: &PgPool,
    subscription_id: Uuid,
    days: i32,
) -> Result<Vec<DailyMetric>> {
    let metrics = sqlx::query_as!(
        DailyMetric,
        r#"
        SELECT
            day,
            subscription_id,
            total_checks,
            successful_checks,
            uptime_ratio,
            avg_latency_ms,
            p95_latency_ms,
            min_latency_ms,
            max_latency_ms,
            failures,
            timeouts,
            errors,
            alerts_triggered
        FROM daily_metrics
        WHERE subscription_id = $1
          AND day >= NOW() - INTERVAL '1 day' * $2
        ORDER BY day DESC
        "#,
        subscription_id,
        days
    )
    .fetch_all(pool)
    .await?;

    Ok(metrics)
}

/// Calculate overall uptime for a subscription (fast aggregation)
pub async fn calculate_uptime_percentage(
    pool: &PgPool,
    subscription_id: Uuid,
    days: i32,
) -> Result<f64> {
    let result = sqlx::query_scalar!(
        r#"
        SELECT AVG(uptime_ratio) AS "uptime!"
        FROM daily_metrics
        WHERE subscription_id = $1
          AND day >= NOW() - INTERVAL '1 day' * $2
        "#,
        subscription_id,
        days
    )
    .fetch_one(pool)
    .await?;

    Ok(result * 100.0)  // Convert to percentage
}
```

### Subscription Management

**File:** `backend/src/database/subscriptions.rs`

```rust
use sqlx::PgPool;
use uuid::Uuid;
use chrono::{DateTime, Utc};
use anyhow::Result;
use serde_json::Value as JsonValue;

#[derive(Debug, Clone)]
pub enum SubscriptionTier {
    Free,
    Basic,
    Standard,
    Pro,
    Enterprise,
}

impl SubscriptionTier {
    pub fn as_str(&self) -> &str {
        match self {
            Self::Free => "free",
            Self::Basic => "basic",
            Self::Standard => "standard",
            Self::Pro => "pro",
            Self::Enterprise => "enterprise",
        }
    }
}

#[derive(Debug)]
pub struct CreateSubscription {
    pub user_wallet: String,
    pub target_type: String,
    pub target_config: JsonValue,
    pub tier: SubscriptionTier,
    pub check_interval_seconds: i32,
    pub payment_tx_hash: Option<String>,
    pub payment_chain: Option<String>,
    pub payment_amount_usdc: Option<i64>,
}

/// Create new subscription (atomic transaction)
pub async fn create_subscription(
    pool: &PgPool,
    params: CreateSubscription,
) -> Result<Uuid> {
    // Start transaction
    let mut tx = pool.begin().await?;

    // Get or create user
    let user_id: Uuid = sqlx::query_scalar!(
        r#"
        INSERT INTO users (wallet_address)
        VALUES ($1)
        ON CONFLICT (wallet_address)
        DO UPDATE SET last_seen_at = NOW()
        RETURNING id
        "#,
        params.user_wallet
    )
    .fetch_one(&mut *tx)
    .await?;

    // Create subscription
    let subscription_id: Uuid = sqlx::query_scalar!(
        r#"
        INSERT INTO subscriptions (
            user_id, target_type, target_config, tier, check_interval_seconds,
            payment_tx_hash, payment_chain, payment_amount_usdc,
            status, activated_at
        )
        VALUES ($1, $2::monitor_type, $3, $4::subscription_tier, $5, $6, $7, $8, 'active', NOW())
        RETURNING id
        "#,
        user_id,
        params.target_type,
        params.target_config,
        params.tier.as_str(),
        params.check_interval_seconds,
        params.payment_tx_hash,
        params.payment_chain,
        params.payment_amount_usdc
    )
    .fetch_one(&mut *tx)
    .await?;

    // Commit transaction
    tx.commit().await?;

    Ok(subscription_id)
}

#[derive(Debug, sqlx::FromRow)]
pub struct Subscription {
    pub id: Uuid,
    pub user_id: Uuid,
    pub target_type: String,
    pub target_config: JsonValue,
    pub tier: String,
    pub check_interval_seconds: i32,
    pub status: String,
    pub created_at: DateTime<Utc>,
    pub activated_at: Option<DateTime<Utc>>,
}

/// Get subscription by ID
pub async fn get_subscription(
    pool: &PgPool,
    subscription_id: Uuid,
) -> Result<Option<Subscription>> {
    let subscription = sqlx::query_as!(
        Subscription,
        r#"
        SELECT
            id, user_id, target_type, target_config, tier,
            check_interval_seconds, status, created_at, activated_at
        FROM subscriptions
        WHERE id = $1
        "#,
        subscription_id
    )
    .fetch_optional(pool)
    .await?;

    Ok(subscription)
}

/// List all active subscriptions for monitoring scheduler
pub async fn list_active_subscriptions(pool: &PgPool) -> Result<Vec<Subscription>> {
    let subscriptions = sqlx::query_as!(
        Subscription,
        r#"
        SELECT
            id, user_id, target_type, target_config, tier,
            check_interval_seconds, status, created_at, activated_at
        FROM subscriptions
        WHERE status = 'active'
        ORDER BY activated_at
        "#
    )
    .fetch_all(pool)
    .await?;

    Ok(subscriptions)
}
```

---

## Testing Strategy

### Unit Tests

**File:** `backend/src/database/checks_test.rs`

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use sqlx::PgPool;

    async fn setup_test_db() -> PgPool {
        let database_url = std::env::var("DATABASE_URL")
            .unwrap_or_else(|_| "postgresql://postgres:lighthouse_dev@localhost:5432/lighthouse_test".to_string());

        PgPool::connect(&database_url).await.unwrap()
    }

    #[tokio::test]
    async fn test_insert_check_result() {
        let pool = setup_test_db().await;

        let subscription_id = Uuid::new_v4();

        let result = CheckResult {
            subscription_id,
            status: CheckStatus::Success,
            http_status: Some(200),
            latency_ms: 145,
            error_message: None,
            alert_triggered: false,
        };

        insert_check_result(&pool, result).await.unwrap();

        let checks = get_recent_checks(&pool, subscription_id, 1).await.unwrap();
        assert_eq!(checks.len(), 1);
        assert_eq!(checks[0].status, "success");
        assert_eq!(checks[0].latency_ms, 145);
    }

    #[tokio::test]
    async fn test_continuous_aggregates() {
        let pool = setup_test_db().await;

        let subscription_id = Uuid::new_v4();

        // Insert 100 checks over 24 hours
        for i in 0..100 {
            let result = CheckResult {
                subscription_id,
                status: if i % 10 == 0 { CheckStatus::Failure } else { CheckStatus::Success },
                http_status: Some(if i % 10 == 0 { 500 } else { 200 }),
                latency_ms: 100 + (i % 50),
                error_message: None,
                alert_triggered: false,
            };
            insert_check_result(&pool, result).await.unwrap();
        }

        // Wait for continuous aggregate refresh (or manually refresh)
        // In production, refresh happens automatically via policy

        let metrics = get_hourly_metrics(&pool, subscription_id, 24).await.unwrap();
        assert!(!metrics.is_empty());

        let uptime = calculate_uptime_percentage(&pool, subscription_id, 1).await.unwrap();
        assert!(uptime > 80.0 && uptime < 95.0);  // ~90% uptime (10% failures)
    }
}
```

### Load Testing

**File:** `backend/tests/load_test.rs`

```rust
use lighthouse_backend::database::{Database, CheckResult, CheckStatus};
use uuid::Uuid;
use tokio::time::{sleep, Duration};

#[tokio::test]
async fn load_test_write_throughput() {
    let db = Database::new(&std::env::var("DATABASE_URL").unwrap())
        .await
        .unwrap();

    let subscription_ids: Vec<Uuid> = (0..500).map(|_| Uuid::new_v4()).collect();

    let start = std::time::Instant::now();
    let mut tasks = vec![];

    // Simulate 500 subscriptions × 1 check/minute = 8.33 checks/sec
    for _ in 0..100 {
        for subscription_id in &subscription_ids {
            let pool = db.pool().clone();
            let sub_id = *subscription_id;

            tasks.push(tokio::spawn(async move {
                let result = CheckResult {
                    subscription_id: sub_id,
                    status: CheckStatus::Success,
                    http_status: Some(200),
                    latency_ms: 150,
                    error_message: None,
                    alert_triggered: false,
                };
                insert_check_result(&pool, result).await.unwrap();
            }));
        }

        sleep(Duration::from_millis(100)).await;  // Stagger writes
    }

    for task in tasks {
        task.await.unwrap();
    }

    let elapsed = start.elapsed();
    let total_writes = 500 * 100;
    let writes_per_sec = total_writes as f64 / elapsed.as_secs_f64();

    println!("Load test: {} writes in {:?} ({:.2} writes/sec)", total_writes, elapsed, writes_per_sec);
    assert!(writes_per_sec > 100.0);  // Should handle 100+ writes/sec easily
}
```

---

## Deployment

### AWS RDS Setup

```bash
# Create RDS PostgreSQL instance with TimescaleDB
aws rds create-db-instance \
  --db-instance-identifier lighthouse-prod \
  --db-instance-class db.t4g.small \
  --engine postgres \
  --engine-version 16.1 \
  --master-username postgres \
  --master-user-password "${DB_PASSWORD}" \
  --allocated-storage 50 \
  --storage-type gp3 \
  --iops 3000 \
  --backup-retention-period 7 \
  --multi-az \
  --vpc-security-group-ids sg-12345678 \
  --db-subnet-group-name lighthouse-db-subnet \
  --region us-east-1 \
  --tags Key=Project,Value=Lighthouse Key=Environment,Value=production

# Wait for instance to be available
aws rds wait db-instance-available --db-instance-identifier lighthouse-prod

# Get endpoint
aws rds describe-db-instances \
  --db-instance-identifier lighthouse-prod \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
# Output: lighthouse-prod.abc123xyz.us-east-1.rds.amazonaws.com

# Connect and install TimescaleDB
export DB_HOST=lighthouse-prod.abc123xyz.us-east-1.rds.amazonaws.com
psql -h $DB_HOST -U postgres -d postgres -c "CREATE EXTENSION timescaledb;"

# Run migrations
export DATABASE_URL="postgresql://postgres:${DB_PASSWORD}@${DB_HOST}:5432/lighthouse"
sqlx migrate run
```

### Docker Self-Hosted

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: timescale/timescaledb:latest-pg16
    container_name: lighthouse-postgres
    environment:
      POSTGRES_DB: lighthouse
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      TIMESCALEDB_TELEMETRY: off
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: ./backend
    container_name: lighthouse-backend
    environment:
      DATABASE_URL: postgresql://postgres:${DB_PASSWORD}@postgres:5432/lighthouse
      RUST_LOG: info
    depends_on:
      postgres:
        condition: service_healthy
    ports:
      - "8080:8080"
    restart: unless-stopped

volumes:
  postgres-data:
```

### Environment Variables

```bash
# .env
DATABASE_URL=postgresql://postgres:lighthouse_dev@localhost:5432/lighthouse

# Production (RDS)
DATABASE_URL=postgresql://postgres:SECURE_PASSWORD@lighthouse-prod.abc123.us-east-1.rds.amazonaws.com:5432/lighthouse
```

---

## Monitoring & Maintenance

### Key Metrics to Track

```sql
-- Hypertable sizes (monitor disk usage)
SELECT
  hypertable_name,
  pg_size_pretty(hypertable_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass)) AS total_size,
  pg_size_pretty(hypertable_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass, 'indexes')) AS index_size
FROM timescaledb_information.hypertables;

-- Compression ratio (verify 10x savings)
SELECT
  hypertable_name,
  pg_size_pretty(before_compression_total_bytes) AS before,
  pg_size_pretty(after_compression_total_bytes) AS after,
  ROUND((before_compression_total_bytes::NUMERIC / NULLIF(after_compression_total_bytes, 0)), 2) AS ratio
FROM timescaledb_information.compression_settings
JOIN timescaledb_information.hypertables USING (hypertable_name);

-- Continuous aggregate lag (should be < 1 hour)
SELECT
  view_name,
  NOW() - materialization_hypertable_end AS lag
FROM timescaledb_information.continuous_aggregates;

-- Slow queries (identify performance issues)
SELECT
  query,
  calls,
  mean_exec_time,
  max_exec_time
FROM pg_stat_statements
WHERE query LIKE '%check_history%' OR query LIKE '%hourly_metrics%'
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Backup Strategy

```bash
# Daily automated backups (via RDS)
aws rds create-db-snapshot \
  --db-instance-identifier lighthouse-prod \
  --db-snapshot-identifier lighthouse-backup-$(date +%Y%m%d)

# Manual backup (self-hosted)
pg_dump -h localhost -U postgres -d lighthouse -Fc -f lighthouse_backup_$(date +%Y%m%d).dump

# Restore from backup
pg_restore -h localhost -U postgres -d lighthouse_restored -Fc lighthouse_backup_20251029.dump
```

---

## Troubleshooting

### Common Issues

**1. Continuous aggregates not updating**

```sql
-- Check refresh policies
SELECT * FROM timescaledb_information.jobs WHERE proc_name = 'policy_refresh_continuous_aggregate';

-- Manually refresh
CALL refresh_continuous_aggregate('hourly_metrics', NOW() - INTERVAL '24 hours', NOW());
```

**2. High disk usage**

```sql
-- Check if compression is working
SELECT * FROM timescaledb_information.jobs WHERE proc_name = 'policy_compression';

-- Manually compress old chunks
SELECT compress_chunk(show_chunks('check_history', older_than => INTERVAL '7 days'));
```

**3. Slow queries**

```sql
-- Add missing index
CREATE INDEX idx_check_history_subscription_time ON check_history(subscription_id, time DESC);

-- Analyze table statistics
ANALYZE check_history;
```

---

## Next Steps

1. **Week 1:** Implement schema, test locally
2. **Week 2:** Add Rust database layer with `sqlx`
3. **Week 3:** Deploy to RDS, test compression
4. **Week 4:** Implement continuous aggregates, benchmark dashboards
5. **Week 5:** Load testing (simulate 500 subscriptions)
6. **Week 6:** Production deployment

---

**Document Status:** Implementation Ready
**Last Updated:** October 29, 2025
**Related Files:**
- `DATABASE-ARCHITECTURE-ANALYSIS.md` (decision rationale)
- `DATABASE-COMPARISON-VISUAL.md` (visual comparison)
