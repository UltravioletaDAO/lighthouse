# Lighthouse Database Options: Visual Comparison

**Date:** October 29, 2025
**Purpose:** Quick visual reference for database decision

---

## Cost Comparison (3-Year TCO)

```
MongoDB Atlas                 PostgreSQL RDS              TimescaleDB RDS
━━━━━━━━━━━━━━━━━━           ━━━━━━━━━━━━━━━━           ━━━━━━━━━━━━━━━━━━
Year 1: $684                  Year 1: $540                Year 1: $360
Year 2: $2,364                Year 2: $1,260              Year 2: $1,080
Year 3: $5,964                Year 3: $1,080              Year 3: $1,080
━━━━━━━━━━━━━━━━━━           ━━━━━━━━━━━━━━━━           ━━━━━━━━━━━━━━━━━━
TOTAL: $9,012                 TOTAL: $2,880               TOTAL: $2,520 ✅


DynamoDB (On-Demand)          InfluxDB Cloud + PostgreSQL
━━━━━━━━━━━━━━━━━━           ━━━━━━━━━━━━━━━━━━━━━━━━
Year 1: $360                  Year 1: $720
Year 2: $3,960                Year 2: $3,960
Year 3: $29,160               Year 3: $9,360
━━━━━━━━━━━━━━━━━━           ━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL: $33,480 ❌             TOTAL: $14,040 ❌
```

**Winner: TimescaleDB** - **$6,492 cheaper than MongoDB over 3 years**

---

## Architecture Fit

```
┌─────────────────────────────────────────────────────────────┐
│              Lighthouse Data Breakdown                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Time-Series (90%)          Relational (10%)                │
│  ├─ Check results (85%)     ├─ Subscriptions (3%)          │
│  ├─ Metrics (10%)           ├─ Alert configs (2%)          │
│  └─ Alerts (5%)             └─ Users (<1%)                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘

┌────────────────────┬────────────┬────────────┬────────────┐
│ Database           │ Time-Series│ Relational │ Total Fit  │
├────────────────────┼────────────┼────────────┼────────────┤
│ MongoDB            │     7/10   │    5/10    │   68%      │
│ DynamoDB           │     4/10   │    3/10    │   38%      │
│ PostgreSQL         │     6/10   │   10/10    │   78%      │
│ TimescaleDB        │     9/10   │   10/10    │   95% ✅   │
│ InfluxDB (+PG)     │    10/10   │   10/10    │   90% *    │
└────────────────────┴────────────┴────────────┴────────────┘
* Requires two databases (complexity penalty)
```

---

## Query Performance Comparison

### Scenario: "Show uptime for subscription X over last 30 days"

**PostgreSQL (Vanilla):**
```sql
SELECT
  date_trunc('day', timestamp) AS day,
  COUNT(*) AS total_checks,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END)::FLOAT / COUNT(*) AS uptime
FROM check_history
WHERE subscription_id = 'X' AND timestamp >= NOW() - INTERVAL '30 days'
GROUP BY day;
```
- **Full scan**: 43,200 rows (30 days × 24 hours × 60 checks)
- **Query time**: ~500ms (unoptimized), ~150ms (with indexes)
- **Problem**: Slow at scale (1000+ subscriptions)

**MongoDB (Time-Series Collections):**
```javascript
db.check_history.aggregate([
  { $match: {
    subscription_id: "X",
    timestamp: { $gte: ISODate("2025-10-01") }
  }},
  { $group: {
    _id: { $dateTrunc: { date: "$timestamp", unit: "day" } },
    total: { $sum: 1 },
    successes: { $sum: { $cond: [{ $eq: ["$status", "success"] }, 1, 0] } }
  }},
  { $project: {
    day: "$_id",
    uptime: { $divide: ["$successes", "$total"] }
  }}
]);
```
- **Bucketed scan**: ~1,440 buckets (30 days × 48 buckets/day)
- **Query time**: ~200ms (optimized)
- **Problem**: Still scanning thousands of documents

**TimescaleDB (Continuous Aggregates):**
```sql
SELECT hour, uptime
FROM hourly_metrics
WHERE subscription_id = 'X' AND hour >= NOW() - INTERVAL '30 days'
ORDER BY hour;
```
- **Pre-computed**: 720 rows (30 days × 24 hours)
- **Query time**: ~20ms (index scan)
- **Advantage**: 7-10x faster, scales to any time range

**DynamoDB:**
```javascript
// Must read all items and aggregate in application
const params = {
  TableName: 'check_history',
  KeyConditionExpression: 'subscription_id = :id AND #ts >= :start',
  ExpressionAttributeNames: { '#ts': 'timestamp' },
  ExpressionAttributeValues: {
    ':id': 'X',
    ':start': Date.now() - (30 * 24 * 60 * 60 * 1000)
  }
};

const items = await dynamodb.query(params).promise();
// Aggregate in application code
const metrics = aggregateByDay(items.Items);
```
- **Full scan + app processing**: 43,200 rows
- **Query time**: ~800ms (network + processing)
- **Cost**: 43,200 read units = $0.01 per query (expensive at scale)
- **Problem**: No server-side aggregation

**InfluxDB:**
```flux
from(bucket: "lighthouse")
  |> range(start: -30d)
  |> filter(fn: (r) => r["subscription_id"] == "X")
  |> aggregateWindow(every: 1d, fn: mean)
```
- **Columnar scan**: Optimized for time-series
- **Query time**: ~50ms (fastest raw query)
- **Problem**: Requires separate database for subscriptions

---

## Storage Efficiency Comparison

### Scenario: 130M check results over 90 days (Year 2 scale)

**Record size estimate:**
```
subscription_id: 16 bytes (UUID)
timestamp:       8 bytes
status:          8 bytes (enum as int)
latency_ms:      4 bytes
http_status:     2 bytes
error:           50 bytes (avg, null for successes)
────────────────────────────
TOTAL:          ~88 bytes per record
```

| Database | Raw Storage | Compressed | Total w/ Indexes | Cost/Month |
|----------|-------------|------------|------------------|------------|
| **PostgreSQL** | 11.4 GB | No compression | ~18 GB | ~$3.60 |
| **MongoDB** | 11.4 GB | **1.1 GB** (10x) | ~2.5 GB | ~$0.50 |
| **TimescaleDB** | 11.4 GB | **1.1 GB** (10x) | ~2.5 GB | ~$0.50 |
| **DynamoDB** | 11.4 GB | AWS-managed | ~11.4 GB | ~$2.85 |
| **InfluxDB** | 11.4 GB | **0.5 GB** (20x) | ~1.0 GB | ~$0.10 |

**Winner: InfluxDB** (best compression), but **TimescaleDB** matches MongoDB (good enough).

**Storage costs are negligible compared to compute/bandwidth costs.**

---

## Multi-Cloud Portability

```
┌─────────────────────────────────────────────────────────────┐
│                    Cloud Provider Support                    │
├─────────────────┬───────┬────────┬───────┬─────────┬────────┤
│ Database        │  AWS  │  GCP   │ Azure │EigenCloud│ Akash │
├─────────────────┼───────┼────────┼───────┼─────────┼────────┤
│ MongoDB         │  ✅   │   ✅   │  ✅   │   ⚠️*   │   ✅  │
│ DynamoDB        │  ✅   │   ❌   │  ❌   │   ❌    │   ❌  │
│ PostgreSQL      │  ✅   │   ✅   │  ✅   │   ✅    │   ✅  │
│ TimescaleDB     │  ✅   │   ✅   │  ✅   │   ✅    │   ✅  │
│ InfluxDB        │  ✅   │   ✅   │  ✅   │   ⚠️**  │   ✅  │
└─────────────────┴───────┴────────┴───────┴─────────┴────────┘

* MongoDB Atlas requires external service (not native EigenCloud)
** InfluxDB self-hosted only (no managed option)

✅ = Managed service available
⚠️ = Self-hosted only
❌ = Not available
```

**Winner: PostgreSQL & TimescaleDB** - Universal support, no lock-in.

---

## Developer Experience (Rust)

### Library Maturity

| Database | Crate | Version | Async | Type Safety | Compile-Time Checks |
|----------|-------|---------|-------|-------------|---------------------|
| MongoDB | `mongodb` | 2.8 | ✅ | Partial (BSON) | ❌ |
| DynamoDB | `aws-sdk-dynamodb` | 1.x | ✅ | ✅ | ❌ |
| PostgreSQL | `tokio-postgres` | 0.7 | ✅ | ✅ | ❌ |
| PostgreSQL | `sqlx` | 0.7 | ✅ | ✅ | **✅** |
| InfluxDB | `influxdb` | 0.5 | ⚠️ (unmaintained) | ❌ | ❌ |

**Winner: `sqlx`** - Compile-time query verification catches bugs at build time.

### Code Example: Insert Check Result

**MongoDB:**
```rust
let doc = doc! {
    "subscription_id": subscription_id.to_string(),
    "timestamp": Utc::now().to_rfc3339(),
    "status": status.to_string(),
    "latency_ms": latency_ms,
};
collection.insert_one(doc, None).await?;
```
- ❌ No type safety (typo in "latency_ms" → runtime error)
- ❌ No schema validation (can insert wrong types)

**sqlx (PostgreSQL/TimescaleDB):**
```rust
sqlx::query!(
    r#"
    INSERT INTO check_history (subscription_id, timestamp, status, latency_ms)
    VALUES ($1, $2, $3, $4)
    "#,
    subscription_id,
    Utc::now(),
    status.to_string(),
    latency_ms
)
.execute(&pool)
.await?;
```
- ✅ Compile-time type checking (wrong type → build error)
- ✅ Query validation against database schema (typo → build error)
- ✅ Auto-generates Rust types from SQL

**Winner: sqlx** - Catches errors before deployment.

---

## Operational Complexity

```
┌─────────────────────────────────────────────────────────────┐
│                 Operational Overhead                         │
├─────────────────┬──────────┬──────────┬─────────┬───────────┤
│ Task            │ MongoDB  │ DynamoDB │PostgreSQL│TimescaleDB│
├─────────────────┼──────────┼──────────┼─────────┼───────────┤
│ Setup           │   ⚠️     │    ✅    │    ✅   │    ✅     │
│ Backups         │   ✅     │    ✅    │    ✅   │    ✅     │
│ Scaling         │   ⚠️     │    ✅    │    ⚠️   │    ⚠️     │
│ Monitoring      │   ✅     │    ✅    │    ✅   │    ✅     │
│ Debugging       │   ✅     │    ⚠️    │    ✅   │    ✅     │
│ Migrations      │   ⚠️     │    ❌    │    ✅   │    ✅     │
│ Self-Hosting    │   ⚠️     │    ❌    │    ✅   │    ✅     │
└─────────────────┴──────────┴──────────┴─────────┴───────────┘

✅ = Simple
⚠️ = Moderate complexity
❌ = Complex or impossible

MongoDB Setup: Requires replica set (3 nodes minimum)
MongoDB Scaling: Manual sharding configuration
MongoDB Migrations: No schema, but data migrations are manual

DynamoDB Scaling: Automatic (but expensive)
DynamoDB Debugging: CloudWatch logs only (no SQL console)
DynamoDB Migrations: No migration tools (manual DynamoDB Streams)
DynamoDB Self-Hosting: Impossible (AWS-only)

PostgreSQL Scaling: Vertical scaling (upgrade instance), read replicas
TimescaleDB Scaling: Same as PostgreSQL + automatic time-partitioning
```

**Winner: PostgreSQL/TimescaleDB** - Industry-standard operations playbook.

---

## Risk Assessment

### MongoDB Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Cost overrun** (Atlas pricing at scale) | High | Medium | Migrate to self-hosted (complex) |
| **Vendor lock-in** (Atlas-specific features) | Medium | Medium | Avoid Atlas Charts, Realm |
| **Performance degradation** (time-series limitations) | Low | High | Cannot fix without migration |
| **Licensing change** (SSPL already happened) | Low | Low | Already SSPL (acceptable) |

**Total Risk Score: Medium** 🟡

### DynamoDB Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **AWS lock-in** (cannot migrate off AWS) | **Certain** | **Critical** | **None** (architectural choice) |
| **Cost explosion** (pay-per-request at scale) | High | Critical | Provisioned capacity (complex) |
| **Query limitations** (no aggregations) | Certain | Medium | Application-level aggregation (slow) |
| **EigenCloud incompatibility** | Certain | High | Cannot deploy to EigenCloud |

**Total Risk Score: High** 🔴

### PostgreSQL/TimescaleDB Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Write performance** (1000+ checks/sec) | Medium | Medium | Vertical scaling, connection pooling |
| **Storage costs** (uncompressed) | Low | Low | TimescaleDB compression (10x savings) |
| **TimescaleDB licensing change** | Low | Medium | Fork or migrate to vanilla PostgreSQL |
| **Expertise gap** (team learning curve) | Low | Low | Extensive documentation, similar to PostgreSQL |

**Total Risk Score: Low** 🟢

### InfluxDB Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Two-database complexity** (InfluxDB + PostgreSQL) | Certain | Medium | Accept complexity or use single DB |
| **Rust client unmaintained** | Certain | High | Maintain fork or rewrite client |
| **Cost overrun** (InfluxDB Cloud) | High | High | Self-host (adds ops complexity) |
| **Learning curve** (Flux language) | Certain | Low | Team training |

**Total Risk Score: Medium-High** 🟡

---

## Migration Complexity If Wrong

### MongoDB → TimescaleDB

**Effort: 2-3 weeks**

```python
# Export from MongoDB
for doc in mongo_collection.find():
    check = {
        'subscription_id': doc['subscription_id'],
        'timestamp': doc['timestamp'],
        'status': doc['status'],
        'latency_ms': doc['latency_ms'],
    }
    pg_cursor.execute("""
        INSERT INTO check_history (subscription_id, timestamp, status, latency_ms)
        VALUES (%(subscription_id)s, %(timestamp)s, %(status)s, %(latency_ms)s)
    """, check)
```

**Challenges:**
- 13M records to migrate (Year 1 scale)
- Downtime required (or dual-write during migration)
- Schema mapping (MongoDB documents → SQL rows)
- Testing (verify data integrity, query parity)

**Cost: ~$5,000** (engineering time + testing + downtime)

### DynamoDB → TimescaleDB

**Effort: 4-6 weeks**

**Challenges:**
- Different data model (NoSQL → SQL)
- Rewrite all queries (DynamoDB API → SQL)
- Export via DynamoDB Streams or S3
- No downtime migration (requires dual-write)
- Extensive testing (behavioral changes)

**Cost: ~$10,000** (major rewrite)

### TimescaleDB → InfluxDB

**Effort: 1-2 weeks**

```python
# Export time-series only
for row in pg_cursor.execute("SELECT * FROM check_history"):
    point = influxdb_client.write_api().write(
        bucket="lighthouse",
        record=Point("check_history")
            .tag("subscription_id", row['subscription_id'])
            .field("latency_ms", row['latency_ms'])
            .time(row['timestamp'])
    )
```

**Challenges:**
- Time-series only (keep PostgreSQL for subscriptions)
- Dual-write during migration
- Query rewrites (SQL → Flux)

**Cost: ~$3,000** (time-series migration only)

### TimescaleDB → Vanilla PostgreSQL

**Effort: 1 day**

```sql
-- Remove TimescaleDB extension
SELECT remove_retention_policy('check_history');
SELECT remove_compression_policy('check_history');
DROP MATERIALIZED VIEW hourly_metrics;
DROP MATERIALIZED VIEW daily_metrics;

-- Continue using PostgreSQL normally
-- (hypertables become regular partitioned tables)
```

**Challenges:** None (TimescaleDB is PostgreSQL underneath)

**Cost: ~$500** (rollback script + testing)

**Winner: TimescaleDB** - Easiest rollback path.

---

## Final Decision Matrix

```
┌─────────────────────────────────────────────────────────────────┐
│                   Decision Criteria Weights                      │
├─────────────────────────┬───────────┬────────────────────────────┤
│ Criterion               │  Weight   │  Reasoning                 │
├─────────────────────────┼───────────┼────────────────────────────┤
│ Time-Series Performance │   25%     │  90% of data               │
│ Cost (3-year TCO)       │   20%     │  Critical for sustainability│
│ Multi-Cloud Portability │   15%     │  EigenCloud strategy       │
│ Operational Simplicity  │   15%     │  Small team                │
│ Developer Experience    │   10%     │  Rust maturity             │
│ Query Flexibility       │   10%     │  Dashboard needs           │
│ Migration Safety        │    5%     │  Rollback option           │
└─────────────────────────┴───────────┴────────────────────────────┘

┌─────────────────┬─────────┬──────────┬────────────┬─────────────┬──────────┬────────────┐
│ Database        │  T-S    │   Cost   │ Multi-Cloud│   Ops      │   Dev    │   Total    │
│                 │ (25%)   │  (20%)   │   (15%)    │  (15%)     │  (10%)   │  (100%)    │
├─────────────────┼─────────┼──────────┼────────────┼─────────────┼──────────┼────────────┤
│ MongoDB         │ 17.5%   │  10.0%   │   12.0%    │    9.0%    │   7.0%   │   55.5%    │
│ DynamoDB        │ 10.0%   │   2.0%   │    0.0%    │   15.0%    │   9.0%   │   36.0%    │
│ PostgreSQL      │ 15.0%   │  18.0%   │   15.0%    │   12.0%    │   9.0%   │   69.0%    │
│ TimescaleDB     │ 22.5%   │  20.0%   │   15.0%    │   12.0%    │   9.0%   │ **78.5%** ✅│
│ InfluxDB (+PG)  │ 25.0%   │   8.0%   │   12.0%    │    6.0%    │   4.0%   │   55.0%    │
└─────────────────┴─────────┴──────────┴────────────┴─────────────┴──────────┴────────────┘
```

**WINNER: TimescaleDB (78.5%)**

**Second Place: PostgreSQL (69.0%)** - Acceptable fallback if TimescaleDB proves complex

**Third Place: MongoDB (55.5%)** - Safe but expensive

**Not Recommended:**
- DynamoDB (36.0%) - AWS lock-in violates multi-cloud principle
- InfluxDB (55.0%) - Two-database complexity not justified at this scale

---

## Recommendation Summary

### Primary: PostgreSQL + TimescaleDB

**Deployment:**
- AWS RDS PostgreSQL 16 (db.t4g.small, 2 vCPU, 2GB RAM, 50GB storage)
- TimescaleDB extension via `CREATE EXTENSION timescaledb`
- Cost: $360/year (Year 1), $1,080/year (Year 2), $1,080/year (Year 3)
- Total 3-year TCO: **$2,520**

**Schema:**
- Standard PostgreSQL tables: `subscriptions`, `users`, `alert_channels`
- TimescaleDB hypertables: `check_history`, `alert_history`
- Continuous aggregates: `hourly_metrics`, `daily_metrics`

**Rust Integration:**
- `sqlx` crate with compile-time query verification
- Connection pooling (20 connections)
- Migrations via `sqlx migrate`

**Scaling Plan:**
- Year 1 (50 subs): db.t4g.small ($30/month)
- Year 2 (500 subs): db.t4g.medium ($60/month)
- Year 3 (5000 subs): db.r6g.large + read replicas ($200/month)

### Fallback: Vanilla PostgreSQL

If TimescaleDB proves too complex or has unexpected issues:
- Use vanilla PostgreSQL with manual partitioning
- Implement application-level aggregation for dashboards
- Cost: Same as TimescaleDB (no extension overhead)
- Migration: 1 day (remove extension)

### Not Recommended: MongoDB, DynamoDB, InfluxDB

**MongoDB:**
- 3-4x more expensive ($9,012 vs $2,520)
- Weaker query performance (no continuous aggregates)
- Atlas vendor lock-in risk

**DynamoDB:**
- 13x more expensive ($33,480 vs $2,520)
- Complete AWS lock-in (cannot deploy to EigenCloud)
- Poor time-series query support

**InfluxDB:**
- 5x more expensive ($14,040 vs $2,520)
- Two-database complexity (InfluxDB + PostgreSQL)
- Weak Rust support (unmaintained crate)

---

**Document Version:** 1.0
**Created:** October 29, 2025
**Author:** Master Architect (Claude Code)
**Related:** `DATABASE-ARCHITECTURE-ANALYSIS.md` (full analysis)
