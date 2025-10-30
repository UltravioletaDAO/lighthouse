# 🔦 Lighthouse (Faro): Universal Trustless Monitoring Platform

**Status:** Design Phase | **Version:** 2.0.0 | **Date:** October 28, 2025

**Names:**
- **Lighthouse** (English) - Guiding light for infrastructure reliability
- **Faro** (Spanish) - Bilingual branding from day 1

**Domains:**
- `lighthouse.ultravioletadao.xyz` (English)
- `faro.ultravioletadao.xyz` (Spanish)

**Position:** Standalone product (self-contained within Karmacadabra repo)

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Why Lighthouse Supersedes WatchTower](#why-lighthouse-supersedes-watchtower)
3. [Architecture Decision](#architecture-decision)
4. [Technology Stack](#technology-stack)
5. [Monitoring Types Deep-Dive](#monitoring-types-deep-dive)
6. [Bilingual Implementation](#bilingual-implementation)
7. [USDC Payment Integration](#usdc-payment-integration)
8. [ChaosChain Integration (Research)](#chaoschain-integration-research)
9. [EigenCloud Deployment (Research)](#eigencloud-deployment-research)
10. [Pricing Strategy](#pricing-strategy)
11. [Implementation Roadmap](#implementation-roadmap)
12. [**🚀 Deployment Guide (STEP-BY-STEP)**](#deployment-guide)
13. [Business Model](#business-model)
14. [Competitive Analysis](#competitive-analysis)
15. [Technical Specifications](#technical-specifications)
16. [Open Questions](#open-questions)
17. [Conclusion](#conclusion)

**📘 Complete Deployment Guide:** See [`DEPLOYMENT-STEP-BY-STEP.md`](./DEPLOYMENT-STEP-BY-STEP.md) for granular instructions

---

## 🎯 Executive Summary

### Vision

**Lighthouse/Faro** is a **universal, trustless monitoring platform** for the Web3 ecosystem. Unlike WatchTower (designed for Karmacadabra-only), Lighthouse monitors:

- ✅ HTTP APIs (JSON responses, status codes, headers)
- ✅ Web pages (HTML content, page load times, SEO checks)
- ✅ GraphQL endpoints (query validation, response schema)
- ✅ WebSocket connections (real-time data streams)
- ✅ Smart contracts (on-chain state, transaction success rates)
- ✅ **AWS CloudWatch Synthetics-style canary flows** (multi-step scenarios)
- ✅ **Native token balances** (AVAX, ETH, MATIC for facilitators)

**Key Innovation:** Pay with **USDC** (universal, multi-chain) instead of GLUE (Karmacadabra-specific).

### Market Opportunity

**Problem:**
- AWS CloudWatch Synthetics: **$0.0012 per check** = $51.84/month for 5-min monitoring
- Datadog Synthetic Monitoring: **$5/test/month**
- Pingdom: **$15/month** (10 monitors)
- UptimeRobot: **$7/month** (50 monitors)

**All require:**
- ❌ Credit cards (KYC friction)
- ❌ Centralized trust (API keys stored on their servers)
- ❌ Fiat payments (crypto projects prefer crypto payments)

**Lighthouse Solution:**
- ✅ **50x cheaper than AWS Synthetics** ($0.20/month vs $51.84/month for 5-min checks)
- ✅ **Crypto-native payments** (USDC on Avalanche, Base, Polygon)
- ✅ **Trustless design** (users control their alert API keys)
- ✅ **Open-source** (audit the code, self-host option)
- ✅ **Multi-chain support** (monitor any blockchain)

### Target Market

**Primary:**
1. **Web3 Projects** (DeFi protocols, NFT platforms, DAOs) - need to monitor smart contracts, APIs, frontends
2. **Crypto Infrastructure** (RPC providers, indexers, oracles) - need high-frequency monitoring with low costs
3. **Karmacadabra Ecosystem** (agents, facilitators, validators) - first customer, reference implementation

**Secondary:**
4. **Traditional Web Apps** (SaaS, e-commerce) - willing to pay with crypto, want privacy
5. **DevOps Teams** - need AWS Synthetics alternative without AWS vendor lock-in

### Competitive Advantage

| Feature | AWS Synthetics | Datadog | Pingdom | **Lighthouse** |
|---------|---------------|---------|---------|----------------|
| **5-min checks (1 endpoint)** | $51.84/mo | $5/mo | $15/mo | **$0.20/mo** |
| **Crypto payments** | ❌ | ❌ | ❌ | **✅ USDC** |
| **Multi-chain support** | ❌ | ❌ | ❌ | **✅ Avalanche/Base/Polygon** |
| **Smart contract monitoring** | ❌ | Limited | ❌ | **✅ Native** |
| **Canary flows** | ✅ | ✅ | ❌ | **✅ Open-source** |
| **Trustless alerts** | ❌ | ❌ | ❌ | **✅ User-controlled keys** |
| **Self-hosted option** | ❌ | ❌ | ❌ | **✅ Docker Compose** |

**Value Proposition:**
- **For crypto projects:** Native blockchain monitoring + crypto payments + 50x cost savings
- **For DevOps teams:** AWS Synthetics features without AWS prices
- **For privacy-focused users:** No credit card, no KYC, no centralized key storage

---

## 🔄 Why Lighthouse Supersedes WatchTower

### WatchTower Limitations (October 28, 2025 design)

| Aspect | WatchTower | Lighthouse |
|--------|------------|------------|
| **Scope** | Karmacadabra-only | Universal (any HTTP/blockchain service) |
| **Payment Token** | GLUE (ecosystem-specific) | USDC (universal, every chain has it) |
| **Target Market** | 53 agents + facilitator | Entire Web3 ecosystem + traditional web |
| **Codebase Location** | `/agents/watchtower/` | `karmacadabra/lighthouse/` (standalone within repo) |
| **Status Codes** | Fixed (200 only) | **Configurable (200, 201, 202, 301, 302, etc)** |
| **Canary Flows** | Not planned | **AWS Synthetics equivalent** |
| **Balance Monitoring** | Not planned | **Native token balances (AVAX, ETH, MATIC)** |
| **Branding** | English-only | **Bilingual (English + Spanish)** |
| **Deployment** | AWS ECS Fargate only | **EigenCloud OR AWS (multi-cloud)** |

### Why Expand Scope?

**1. Market Size:**
- Karmacadabra: ~53 agents = max 53 customers (~$2-3/month revenue)
- Web3 ecosystem: 1000+ projects = potential 1000+ customers (~$200-1000/month revenue)
- **10-100x larger addressable market**

**2. Competitive Moat:**
- "Karmacadabra monitoring" = niche tool
- "AWS Synthetics alternative for Web3" = **industry-standard tool**
- Lighthouse can become the **de facto monitoring solution for crypto projects**

**3. Token Economics:**
- GLUE: Limited liquidity, tied to Karmacadabra success
- USDC: **Universal, liquid, stable** - users already hold it
- **Lower friction for user acquisition**

**4. Product Vision:**
- WatchTower: Internal tool (like AWS X-Ray for AWS services)
- Lighthouse: **Standalone product** (like Datadog - works with any infrastructure)

**5. Revenue Sustainability:**
- WatchTower break-even: 370 subscribers at current GLUE price
- Lighthouse break-even: **185 subscribers** (USDC pricing is stable)
- **2x faster path to sustainability**

### Migration Path

**Phase 1 (Week 1-2):** Build Lighthouse MVP with HTTP monitoring
**Phase 2 (Week 3-4):** Add canary flows + blockchain monitoring
**Phase 3 (Week 5):** Migrate Karmacadabra agents from manual checks to Lighthouse
**Phase 4 (Week 6+):** Public launch, onboard external Web3 projects

**WatchTower code:** Archive as reference, not deployed. Lighthouse is the production system.

---

## 🏗️ Architecture Decision

### Standalone vs Integrated

**Option A: Integrate into Karmacadabra codebase (`/agents/lighthouse/`)**

**Pros:**
- Reuse existing infrastructure (ERC8004BaseAgent, shared libraries)
- Faster initial development

**Cons:**
- ❌ **Conceptual coupling** - Lighthouse is NOT a Karmacadabra agent (it monitors agents, not IS an agent)
- ❌ **Different target audience** - Karmacadabra = AI agents, Lighthouse = DevOps/monitoring
- ❌ **Scaling independently** - Lighthouse might grow 10x faster than Karmacadabra
- ❌ **Branding confusion** - "Is Lighthouse part of Karmacadabra or separate?"

**Option B: Standalone project (RECOMMENDED) ✅**

**Pros:**
- ✅ **Clear separation** - Lighthouse is its own product/brand
- ✅ **Independent evolution** - Can pivot features without affecting Karmacadabra
- ✅ **Separate funding** - Can seek external investment/grants
- ✅ **Open-source appeal** - "Universal monitoring tool" vs "Karmacadabra internal tool"
- ✅ **Multi-cloud strategy** - Not tied to Karmacadabra's AWS infrastructure

**Cons:**
- Some code duplication (payment verification, authentication)
- Separate deployment pipeline

**DECISION: Option B - Standalone Project**

**Location:**
```
z:\ultravioleta\dao\karmacadabra\lighthouse\  # Windows path
/mnt/z/ultravioleta/dao/karmacadabra/lighthouse/  # WSL path

lighthouse/                     # ← Standalone within karmacadabra repo
├── README.md                   # Bilingual documentation
├── README.es.md
├── ARCHITECTURE.md
├── docker-compose.yml
├── backend/
├── frontend/
├── contracts/ (optional)
├── terraform/
├── docs/
├── scripts/
└── tests/
```

**Development Strategy:**
1. **Current location:** `karmacadabra/lighthouse/` (standalone but within repo)
2. **Architecture:** Self-contained (no dependencies on karmacadabra code)
3. **Future option:** Can extract to separate repository if needed
4. **Deployment:** Independent from Karmacadabra services

### Self-Contained Design Principles

**1. No Karmacadabra dependencies:**
- Don't import from `shared/` (copy patterns, don't link)
- Don't rely on Karmacadabra contracts (use own USDC integration)
- Don't assume Karmacadabra infrastructure (works on any cloud)

**2. Universal by default:**
- Monitor any HTTP endpoint (not just Karmacadabra agents)
- Support any blockchain (not just Avalanche Fuji)
- Accept any USDC chain (Avalanche, Base, Polygon, mainnet)

**3. Easy self-hosting:**
- Docker Compose one-command deployment
- Environment variables for all config
- No AWS-specific dependencies (works on GCP, Azure, EigenCloud, bare metal)

---

## 🛠️ Technology Stack

### Backend Framework Decision

**Option A: Python + FastAPI (Like Karmacadabra agents)**

**Pros:**
- Fast development (similar to existing codebase)
- Rich ecosystem (httpx, playwright, web3.py)
- Easy async/await for concurrent checks

**Cons:**
- Python GIL limits CPU parallelism
- Higher memory usage (100-200MB per worker)

**Option B: Rust + Axum (Like x402-rs facilitator)**

**Pros:**
- **10x lower memory usage** (10-20MB per worker)
- **10x higher throughput** (handle 1000s of concurrent checks)
- **Type safety** (fewer runtime errors)
- Better for production monitoring (reliability critical)

**Cons:**
- Slower development (steeper learning curve)
- Smaller ecosystem (fewer monitoring libraries)

**DECISION: Hybrid Approach ✅**

**Rust backend** (core monitoring engine):
- HTTP health checks (reqwest)
- WebSocket monitoring (tokio-tungstenite)
- Blockchain RPC calls (alloy-rs)
- Database operations (PostgreSQL/TimescaleDB via sqlx)
- x402 payment verification

**Python workers** (complex scenarios):
- Canary flows (Playwright for browser automation)
- GraphQL validation (gql library)
- AI-powered incident analysis (future: CrewAI integration)

**Why hybrid?**
- Rust handles 95% of workload (simple HTTP checks) efficiently
- Python handles 5% of edge cases (complex browser automation) flexibly
- Best of both worlds: **performance + flexibility**

### Core Technology Choices

**Language & Framework:**
```
Backend Core:    Rust 1.75+ + Axum 0.7
Workers:         Python 3.11+ + Celery
API Layer:       Axum (Rust) + REST + WebSocket
```

**Database:**
```
Primary:         PostgreSQL 16 + TimescaleDB 2.14 (hybrid relational + time-series)
Cache:           Redis 7.2 (rate limiting, ephemeral data)
Time-series:     TimescaleDB hypertables (10x compression, continuous aggregates)
```

**Monitoring Engines:**
```
HTTP:            reqwest (Rust) - async HTTP client
WebSocket:       tokio-tungstenite (Rust) - WebSocket client
Blockchain:      alloy-rs (Rust) - Ethereum RPC client
Browser:         Playwright (Python) - headless browser automation
GraphQL:         reqwest + JSON parsing (Rust)
```

**Payments:**
```
Token:           USDC (Circle USD Coin)
Protocol:        x402 HTTP payment protocol
Mechanism:       EIP-3009 transferWithAuthorization
Chains:          Avalanche Fuji, Base Sepolia, Polygon Mumbai (testnets)
                 Avalanche C-Chain, Base, Polygon (mainnet)
```

**Deployment:**
```
Primary:         AWS EC2 Graviton2 (t4g.micro → t4g.medium) + EBS volumes
Database:        Self-managed TimescaleDB on EC2 (persistent EBS storage)
Alternative:     EigenCloud for backend compute (NOT for database - too slow)
Orchestration:   Docker Compose (dev), Terraform (prod)
Cost:            $8/month (MVP) → $72/month (5,000 subs) → $165/month (RDS Multi-AZ)
Migration Path:  EC2 self-managed → AWS RDS Multi-AZ when revenue > $5K/month
```

**Infrastructure:**
```
Load Balancer:   Cloudflare (DDoS protection, SSL termination)
DNS:             Cloudflare DNS (lighthouse.ultravioletadao.xyz)
Secrets:         AWS Secrets Manager OR Hashicorp Vault
Monitoring:      Self-hosted Lighthouse instance (dogfooding)
```

### Why TimescaleDB for Time-Series Data?

**Alternatives considered:**
- **MongoDB Time-Series:** Cannot update/delete individual measurements, limited indexes, weak Rust support
- **InfluxDB:** Purpose-built but requires TWO databases (Postgres + Influx), 5x more expensive
- **Prometheus:** Metrics-only, not general-purpose storage
- **DynamoDB:** 13x more expensive, AWS vendor lock-in, no self-hosting

**TimescaleDB (PostgreSQL Extension):**
```sql
-- Create hypertable for time-series data
CREATE TABLE check_history (
  time TIMESTAMPTZ NOT NULL,
  subscription_id UUID NOT NULL,
  status_code INT,
  response_time_ms INT,
  success BOOLEAN
);

SELECT create_hypertable('check_history', 'time');

-- Add compression (10x storage savings)
ALTER TABLE check_history SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'subscription_id'
);

-- Auto-delete data after 90 days
SELECT add_retention_policy('check_history', INTERVAL '90 days');

-- Continuous aggregates for instant dashboards
CREATE MATERIALIZED VIEW hourly_metrics
WITH (timescaledb.continuous) AS
SELECT subscription_id, time_bucket('1 hour', time) AS hour,
       AVG(response_time_ms) as avg_latency,
       COUNT(*) FILTER (WHERE success) * 100.0 / COUNT(*) as uptime_pct
FROM check_history
GROUP BY subscription_id, hour;
```

**Advantages:**
- ✅ **Hybrid data model** - Time-series (90%) + relational (10%) in same DB
- ✅ **10x compression** - Same as MongoDB, but with full SQL features
- ✅ **Continuous aggregates** - Pre-computed metrics for <20ms dashboard queries
- ✅ **No limitations** - Full UPDATE/DELETE support, unlimited indexes, ACID transactions
- ✅ **Multi-cloud portable** - Works on AWS, GCP, Azure, EigenCloud, self-hosted
- ✅ **Cost efficient** - $2,520 over 3 years vs $9,012 MongoDB Atlas
- ✅ **Rust ecosystem** - `sqlx` crate with compile-time query verification
- ✅ **Migration safety** - It's PostgreSQL underneath, can disable extension anytime

**Cost Comparison (3-Year TCO):**
```
TimescaleDB (EC2):  $1,230  (self-managed)
TimescaleDB (RDS):  $2,609  (managed)
MongoDB Atlas:      $9,012  (3.6x more expensive)
DynamoDB:          $33,480  (13x more expensive)
```

**See detailed analysis:** `lighthouse/DATABASE-ARCHITECTURE-ANALYSIS.md`

---

## 🔍 Monitoring Types Deep-Dive

### 4.1 HTTP/API Monitoring

**Features:**

1. **Flexible Status Code Configuration**

Users define what "success" means for their API:

```rust
pub struct HttpCheckConfig {
    pub url: String,
    pub method: HttpMethod,  // GET, POST, PUT, DELETE
    pub headers: HashMap<String, String>,
    pub body: Option<String>,

    // Success criteria (user-configurable)
    pub valid_status_codes: Vec<u16>,  // [200, 201, 202]
    pub max_latency_ms: u32,            // 5000
    pub expected_headers: Option<HashMap<String, String>>,
    pub body_validation: Option<BodyValidation>,
}

pub enum BodyValidation {
    Contains(String),              // Body contains "healthy"
    JsonPath {                     // JSONPath query
        path: String,              // $.status
        expected_value: JsonValue  // "ok"
    },
    Regex(String),                 // Regex pattern match
    JsonSchema(serde_json::Value), // Validate against JSON schema
}
```

**Example configurations:**

```javascript
// REST API - Accept multiple success codes
{
  "url": "https://api.example.com/users",
  "method": "POST",
  "valid_status_codes": [200, 201, 202],  // Created or Accepted
  "max_latency_ms": 3000,
  "body_validation": {
    "json_path": {
      "path": "$.user.id",
      "expected_value": {"type": "number"}
    }
  }
}

// Web page - Allow redirects
{
  "url": "https://example.com/login",
  "method": "GET",
  "valid_status_codes": [200, 301, 302],  // OK or redirects
  "expected_headers": {
    "content-type": "text/html"
  }
}

// Health check - Exact match
{
  "url": "https://validator.karmacadabra.xyz/health",
  "method": "GET",
  "valid_status_codes": [200],
  "body_validation": {
    "contains": "healthy"
  }
}
```

2. **Response Time Tracking**

```rust
pub struct CheckResult {
    pub timestamp: DateTime<Utc>,
    pub status: CheckStatus,
    pub http_status: Option<u16>,
    pub latency_ms: u32,

    // Detailed timing breakdown
    pub timings: HttpTimings,

    pub error: Option<String>,
    pub response_body: Option<String>,  // Truncated to 1KB
}

pub struct HttpTimings {
    pub dns_lookup_ms: u32,
    pub tcp_connect_ms: u32,
    pub tls_handshake_ms: u32,
    pub time_to_first_byte_ms: u32,
    pub total_ms: u32,
}
```

**Alert triggers:**
- HTTP status not in `valid_status_codes` list
- Response time > `max_latency_ms`
- Body validation fails
- Connection timeout (configurable, default 30s)
- Certificate expiration (SSL/TLS monitoring)

3. **Header Validation**

```javascript
// Example: CORS headers check
{
  "url": "https://api.example.com",
  "expected_headers": {
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "GET, POST, PUT, DELETE"
  }
}
```

**Use cases:**
- Verify CORS headers are set correctly
- Check cache headers (Cache-Control, ETag)
- Validate security headers (CSP, X-Frame-Options)
- Monitor API versioning (X-API-Version)

### 4.2 Canary Flows (AWS CloudWatch Synthetics Equivalent)

**Definition:** Multi-step scenarios that test complete user workflows, not just single endpoints.

**Example 1: E-commerce Checkout Flow**

```javascript
{
  "name": "Checkout Flow",
  "steps": [
    {
      "step": 1,
      "name": "Homepage loads",
      "action": "GET",
      "url": "https://shop.example.com",
      "expect": {
        "status": 200,
        "body_contains": "Add to Cart"
      }
    },
    {
      "step": 2,
      "name": "Product page loads",
      "action": "GET",
      "url": "https://shop.example.com/product/123",
      "expect": {
        "status": 200,
        "json_path": {
          "path": "$.product.price",
          "condition": "> 0"
        }
      }
    },
    {
      "step": 3,
      "name": "Add to cart",
      "action": "POST",
      "url": "https://shop.example.com/api/cart",
      "headers": {
        "Authorization": "Bearer ${AUTH_TOKEN}"
      },
      "body": {
        "product_id": 123,
        "quantity": 1
      },
      "expect": {
        "status": [200, 201],
        "json_path": {
          "path": "$.cart.items.length",
          "value": 1
        }
      },
      "extract": {
        "CART_ID": "$.cart.id"
      }
    },
    {
      "step": 4,
      "name": "Checkout",
      "action": "POST",
      "url": "https://shop.example.com/api/checkout",
      "body": {
        "cart_id": "${CART_ID}",
        "payment_method": "test_card"
      },
      "expect": {
        "status": 200,
        "json_path": {
          "path": "$.order.status",
          "value": "confirmed"
        }
      }
    }
  ],
  "on_failure": {
    "alert": "critical",
    "screenshot": true,
    "retry_count": 3
  }
}
```

**Example 2: Karmacadabra Purchase Flow**

```javascript
{
  "name": "Karma-Hello Purchase Flow",
  "steps": [
    {
      "step": 1,
      "name": "Agent health check",
      "action": "GET",
      "url": "https://karma-hello.karmacadabra.ultravioletadao.xyz/health",
      "expect": {
        "status": 200,
        "json_path": {
          "path": "$.status",
          "value": "healthy"
        }
      }
    },
    {
      "step": 2,
      "name": "Discover agent capabilities",
      "action": "GET",
      "url": "https://karma-hello.karmacadabra.ultravioletadao.xyz/.well-known/agent-card",
      "expect": {
        "status": 200,
        "json_path": {
          "path": "$.skills[0].name",
          "value": "get_chat_logs"
        }
      },
      "extract": {
        "SKILL_PRICE": "$.skills[0].price.amount"
      }
    },
    {
      "step": 3,
      "name": "Sign payment authorization",
      "action": "CUSTOM",
      "script": "sign_eip3009_payment",
      "params": {
        "amount": "${SKILL_PRICE}",
        "seller": "0x2C3...",
        "token": "0x3D1..."
      },
      "extract": {
        "PAYMENT_SIG": "output.signature"
      }
    },
    {
      "step": 4,
      "name": "Purchase chat logs",
      "action": "POST",
      "url": "https://karma-hello.karmacadabra.ultravioletadao.xyz/api/get_chat_logs",
      "headers": {
        "X-Payment": "${PAYMENT_SIG}"
      },
      "body": {
        "date": "2025-10-20"
      },
      "expect": {
        "status": 200,
        "json_path": {
          "path": "$.logs",
          "type": "array",
          "min_length": 1
        }
      }
    },
    {
      "step": 5,
      "name": "Verify on-chain transaction",
      "action": "BLOCKCHAIN",
      "chain": "avalanche_fuji",
      "contract": "0x3D1...",
      "function": "balanceOf",
      "params": ["${SELLER_ADDRESS}"],
      "expect": {
        "condition": "> ${PREVIOUS_BALANCE}"
      }
    }
  ],
  "schedule": "*/15 * * * *",  // Every 15 minutes
  "on_failure": {
    "alert": "critical",
    "channels": ["discord", "telegram"],
    "screenshot": true
  }
}
```

**Example 3: Authentication Flow**

```javascript
{
  "name": "Login Flow",
  "steps": [
    {
      "step": 1,
      "name": "Visit login page",
      "action": "GET",
      "url": "https://app.example.com/login",
      "expect": {
        "status": 200,
        "body_contains": "Sign in"
      }
    },
    {
      "step": 2,
      "name": "Submit credentials",
      "action": "POST",
      "url": "https://app.example.com/api/auth/login",
      "body": {
        "email": "test@example.com",
        "password": "${TEST_PASSWORD}"
      },
      "expect": {
        "status": 200,
        "json_path": {
          "path": "$.token",
          "type": "string"
        }
      },
      "extract": {
        "AUTH_TOKEN": "$.token"
      }
    },
    {
      "step": 3,
      "name": "Access protected resource",
      "action": "GET",
      "url": "https://app.example.com/api/dashboard",
      "headers": {
        "Authorization": "Bearer ${AUTH_TOKEN}"
      },
      "expect": {
        "status": 200,
        "json_path": {
          "path": "$.user.email",
          "value": "test@example.com"
        }
      }
    }
  ]
}
```

**Canary Flow Features:**

1. **Variable Extraction:** Extract values from responses (step 3 → step 4)
2. **Conditional Logic:** Skip steps based on previous results
3. **Custom Scripts:** Run custom code (e.g., sign payment, generate OTP)
4. **Screenshot on Failure:** Playwright captures page state
5. **Timing Breakdown:** Measure each step's latency
6. **Retry Logic:** Retry failed steps before alerting

**Implementation (Rust + Python):**

```rust
// Rust: Orchestrate canary flow
pub async fn run_canary_flow(flow: CanaryFlow) -> FlowResult {
    let mut context = HashMap::new();  // Store extracted variables

    for step in flow.steps {
        let result = match step.action {
            Action::Http(req) => execute_http_step(req, &context).await?,
            Action::Custom(script) => {
                // Call Python worker for complex logic
                execute_python_script(script, &context).await?
            },
            Action::Blockchain(query) => execute_blockchain_step(query).await?,
        };

        // Extract variables for next steps
        if let Some(extract) = step.extract {
            for (var_name, json_path) in extract {
                context.insert(var_name, extract_value(&result, &json_path));
            }
        }

        // Check expectations
        if !validate_step(result, &step.expect) {
            return FlowResult::Failed {
                failed_step: step.step,
                error: result.error,
                screenshot: capture_screenshot().await,
            };
        }
    }

    FlowResult::Success
}
```

```python
# Python: Playwright browser automation for complex scenarios
from playwright.async_api import async_playwright

async def execute_browser_canary(flow):
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()

        for step in flow['steps']:
            if step['action'] == 'NAVIGATE':
                await page.goto(step['url'])
            elif step['action'] == 'CLICK':
                await page.click(step['selector'])
            elif step['action'] == 'FILL':
                await page.fill(step['selector'], step['value'])

            # Screenshot on failure
            if not await validate_step(page, step['expect']):
                await page.screenshot(path=f"failure_{step['step']}.png")
                return {'status': 'failed', 'step': step['step']}

        await browser.close()
        return {'status': 'success'}
```

### 4.3 Blockchain Monitoring

**4.3.1 Smart Balance Monitoring (Facilitator-Specific)**

**Use case:** Monitor native token balances for facilitators (AVAX, ETH, MATIC) to prevent out-of-gas failures.

```rust
pub struct BalanceMonitor {
    pub chain: Blockchain,
    pub address: Address,
    pub token: TokenType,
    pub alert_threshold: f64,  // e.g., 0.1 AVAX
    pub critical_threshold: f64,  // e.g., 0.01 AVAX
}

pub enum TokenType {
    Native,           // AVAX, ETH, MATIC
    ERC20(Address),   // USDC, GLUE, etc
}

pub enum Blockchain {
    AvalancheFuji,
    AvalancheMainnet,
    BaseSepolia,
    BaseMainnet,
    PolygonMumbai,
    PolygonMainnet,
}
```

**Example: Monitor Avalanche Facilitator Balance**

```javascript
{
  "target_type": "blockchain_balance",
  "chain": "avalanche_fuji",
  "address": "0xABC123...",  // Facilitator wallet
  "token": "native",         // AVAX
  "alert_threshold": 0.1,    // Alert if < 0.1 AVAX
  "critical_threshold": 0.01, // Critical if < 0.01 AVAX
  "check_frequency": 300     // Every 5 minutes
}
```

**Alert message:**
```
🚨 Low Balance Alert: Avalanche Facilitator

Address: 0xABC123...
Current Balance: 0.08 AVAX
Alert Threshold: 0.1 AVAX
Critical Threshold: 0.01 AVAX

Action Required: Fund facilitator wallet to prevent transaction failures.

Next Check: 2025-10-28T10:05:00Z
```

**Implementation:**

```rust
pub async fn check_native_balance(
    chain: Blockchain,
    address: Address,
    threshold: f64,
) -> CheckResult {
    let provider = get_provider(chain);
    let balance = provider.get_balance(address).await?;
    let balance_eth = wei_to_eth(balance);

    CheckResult {
        status: if balance_eth < threshold {
            CheckStatus::Failed
        } else {
            CheckStatus::Success
        },
        value: balance_eth,
        message: format!("Balance: {} {}", balance_eth, chain.native_token()),
    }
}
```

**Why NOT monitor GLUE or other ERC-20 tokens?**
- ❌ GLUE balance doesn't affect operation (agents don't need GLUE to function)
- ✅ Native tokens (AVAX/ETH/MATIC) are critical (needed for gas)
- Focus on **operational health**, not economic metrics

**4.3.2 Smart Contract State Monitoring (Optional Phase 2)**

```javascript
{
  "target_type": "smart_contract",
  "chain": "avalanche_fuji",
  "contract_address": "0x3D1...",
  "function": "paused",
  "expected_result": false,
  "alert_on_mismatch": true
}
```

**Use cases:**
- Check if contract is paused (emergency shutdown detection)
- Monitor contract ownership changes
- Track contract balance thresholds
- Verify oracle data freshness

**4.3.3 Transaction Success Rate Monitoring (Optional Phase 2)**

```javascript
{
  "target_type": "transaction_success_rate",
  "chain": "avalanche_fuji",
  "address": "0xABC...",  // Facilitator address
  "time_window": "1h",
  "min_success_rate": 0.95,  // 95%
  "alert_on_threshold": true
}
```

**Implementation:** Query blockchain for recent transactions, calculate success/failure ratio.

### 4.4 GraphQL Monitoring

```javascript
{
  "target_type": "graphql",
  "url": "https://api.example.com/graphql",
  "query": "query { users { id name } }",
  "valid_status_codes": [200],
  "expected_schema": {
    "data": {
      "users": [
        {
          "id": "string",
          "name": "string"
        }
      ]
    }
  }
}
```

### 4.5 WebSocket Monitoring

```rust
pub async fn check_websocket(url: String) -> CheckResult {
    let (mut ws_stream, _) = connect_async(url).await?;

    // Send ping
    ws_stream.send(Message::Ping(vec![])).await?;

    // Wait for pong (with timeout)
    let response = timeout(
        Duration::from_secs(10),
        ws_stream.next()
    ).await??;

    match response {
        Some(Message::Pong(_)) => CheckResult::success(),
        _ => CheckResult::failed("No pong received"),
    }
}
```

**Use cases:**
- WebSocket connection health
- Real-time data stream validation
- Latency monitoring for real-time apps

---

## 🌍 Bilingual Implementation

### Strategy: True Bilingualism from Day 1

**NOT:** English-first, Spanish later
**YES:** Simultaneous development, equal priority

### 1. Domain Routing

```nginx
# nginx config
server {
    server_name lighthouse.ultravioletadao.xyz;
    location / {
        proxy_pass http://backend:8080;
        proxy_set_header X-Language "en";
    }
}

server {
    server_name faro.ultravioletadao.xyz;
    location / {
        proxy_pass http://backend:8080;
        proxy_set_header X-Language "es";
    }
}
```

**Backend language detection:**

```rust
pub fn detect_language(req: &Request) -> Language {
    // Priority 1: Domain name
    if req.uri().host() == Some("faro.ultravioletadao.xyz") {
        return Language::Spanish;
    }

    // Priority 2: Accept-Language header
    if let Some(accept_lang) = req.headers().get("Accept-Language") {
        if accept_lang.to_str().unwrap().starts_with("es") {
            return Language::Spanish;
        }
    }

    // Default: English
    Language::English
}
```

### 2. i18n String Management

**File structure:**
```
lighthouse/
├── i18n/
│   ├── en.json
│   └── es.json
```

**en.json:**
```json
{
  "app_name": "Lighthouse",
  "tagline": "Universal Trustless Monitoring for Web3",
  "alerts": {
    "downtime": {
      "title": "Downtime Alert: {target}",
      "message": "Your monitored service is DOWN",
      "error": "Error: {error}",
      "last_success": "Last successful check: {time}"
    }
  },
  "pricing": {
    "basic": {
      "name": "Basic",
      "description": "For small projects and testing"
    }
  }
}
```

**es.json:**
```json
{
  "app_name": "Faro",
  "tagline": "Monitoreo Universal Sin Confianza para Web3",
  "alerts": {
    "downtime": {
      "title": "Alerta de Caída: {target}",
      "message": "Tu servicio monitoreado está CAÍDO",
      "error": "Error: {error}",
      "last_success": "Última verificación exitosa: {time}"
    }
  },
  "pricing": {
    "basic": {
      "name": "Básico",
      "description": "Para proyectos pequeños y pruebas"
    }
  }
}
```

**Rust i18n library:**

```rust
use fluent::{FluentBundle, FluentResource};

pub struct I18n {
    bundles: HashMap<Language, FluentBundle>,
}

impl I18n {
    pub fn t(&self, lang: Language, key: &str, args: Option<HashMap<&str, &str>>) -> String {
        let bundle = &self.bundles[&lang];
        let msg = bundle.get_message(key).unwrap();
        let pattern = msg.value().unwrap();

        let mut errors = vec![];
        bundle.format_pattern(&pattern, args, &mut errors).to_string()
    }
}

// Usage
let i18n = I18n::new();
let title = i18n.t(
    Language::Spanish,
    "alerts.downtime.title",
    Some(hashmap!{"target" => "Validator Agent"})
);
// → "Alerta de Caída: Validator Agent"
```

### 3. Documentation Sync

**Mandatory process:**
1. Write feature doc in English (`docs/features/canary-flows.md`)
2. **IMMEDIATELY** translate to Spanish (`docs/features/canary-flows.es.md`)
3. Add both to Git commit (NEVER merge English-only docs)

**Automation:**

```bash
# Pre-commit hook
#!/bin/bash
# Check for .md files without .es.md counterpart
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' | grep -v '\.es\.md$'); do
    es_file="${file%.md}.es.md"
    if [ ! -f "$es_file" ]; then
        echo "ERROR: Missing Spanish translation for $file"
        echo "Please create $es_file before committing"
        exit 1
    fi
done
```

### 4. Alert Messages

**Discord alert (English):**
```
🔴 Downtime Alert: Validator Agent

Your monitored service is DOWN

Target: https://validator.karmacadabra.xyz/health
Error: HTTP 503 Service Unavailable
Last Success: 2025-10-28T09:55:00Z (5 minutes ago)
Uptime (30d): 99.87%

Powered by Lighthouse | lighthouse.ultravioletadao.xyz
```

**Discord alert (Spanish):**
```
🔴 Alerta de Caída: Agente Validador

Tu servicio monitoreado está CAÍDO

Objetivo: https://validator.karmacadabra.xyz/health
Error: HTTP 503 Servicio No Disponible
Último Éxito: 2025-10-28T09:55:00Z (hace 5 minutos)
Tiempo Activo (30d): 99.87%

Desarrollado por Faro | faro.ultravioletadao.xyz
```

**Language selection:** Users specify preferred language in alert config:

```json
{
  "alert_channels": [
    {
      "type": "discord",
      "webhook_url": "...",
      "language": "es"
    }
  ]
}
```

### 5. Frontend (Phase 2)

**React i18n:**

```typescript
// src/i18n/index.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: require('./locales/en.json') },
      es: { translation: require('./locales/es.json') },
    },
    lng: 'en',
    fallbackLng: 'en',
    interpolation: { escapeValue: false },
  });

export default i18n;
```

```tsx
// Component usage
import { useTranslation } from 'react-i18next';

function PricingTable() {
  const { t } = useTranslation();

  return (
    <div>
      <h1>{t('pricing.title')}</h1>
      <p>{t('pricing.basic.description')}</p>
    </div>
  );
}
```

**URL structure:**
- English: `https://lighthouse.ultravioletadao.xyz/pricing`
- Spanish: `https://faro.ultravioletadao.xyz/precios`

---

## 💰 USDC Payment Integration

### Why USDC vs GLUE?

| Aspect | GLUE | USDC |
|--------|------|------|
| **Availability** | Avalanche Fuji only | Every major chain |
| **Liquidity** | Low (Karmacadabra ecosystem) | High (billions in circulation) |
| **Price Stability** | Volatile (new token) | Stable ($1 = 1 USDC) |
| **User Acquisition** | Friction (need to acquire GLUE) | Easy (users already hold USDC) |
| **Market Perception** | "Karmacadabra tool" | "Universal tool" |

**Decision:** USDC for Lighthouse, GLUE stays for Karmacadabra agents

### EIP-3009 Support in USDC

**Good news:** Circle's USDC v2 implements EIP-3009 `transferWithAuthorization` ✅

**Supported chains:**
- ✅ Ethereum Mainnet
- ✅ Avalanche C-Chain
- ✅ Base
- ✅ Polygon
- ✅ Arbitrum
- ✅ Optimism

**⚠️ Important caveat:** Polygon bridged USDC (USDC.e) has **different EIP-712 signature format** (not standard EIP-3009)

**Solution:** Support both formats:

```rust
pub enum UsdcVariant {
    Native,      // Circle-native USDC (standard EIP-3009)
    Bridged,     // Bridged USDC (custom signature format)
}

pub async fn verify_usdc_payment(
    chain: Blockchain,
    authorization: TransferAuthorization,
) -> Result<bool> {
    let usdc_variant = detect_usdc_variant(chain);

    match usdc_variant {
        UsdcVariant::Native => verify_eip3009(authorization).await,
        UsdcVariant::Bridged => verify_polygon_bridged(authorization).await,
    }
}
```

### Multi-Chain USDC Support

**Contract addresses (testnets):**

```rust
pub fn usdc_address(chain: Blockchain) -> Address {
    match chain {
        Blockchain::AvalancheFuji =>
            "0x5425890298aed601595a70AB815c96711a31Bc65".parse().unwrap(),
        Blockchain::BaseSepolia =>
            "0x036CbD53842c5426634e7929541eC2318f3dCF7e".parse().unwrap(),
        Blockchain::PolygonMumbai =>
            "0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97".parse().unwrap(),
        _ => panic!("Unsupported chain"),
    }
}
```

**Mainnet addresses:** (production deployment)

```rust
pub fn usdc_address_mainnet(chain: Blockchain) -> Address {
    match chain {
        Blockchain::AvalancheMainnet =>
            "0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E".parse().unwrap(),
        Blockchain::BaseMainnet =>
            "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913".parse().unwrap(),
        Blockchain::PolygonMainnet =>
            "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174".parse().unwrap(),
        _ => panic!("Unsupported chain"),
    }
}
```

### x402 Protocol Integration

**Reuse x402-rs facilitator pattern:**

```rust
#[derive(Deserialize)]
pub struct TransferAuthorization {
    pub from: Address,
    pub to: Address,
    pub value: U256,
    pub valid_after: U256,
    pub valid_before: U256,
    pub nonce: [u8; 32],
    pub v: u8,
    pub r: [u8; 32],
    pub s: [u8; 32],
}

pub async fn verify_and_execute_usdc_payment(
    chain: Blockchain,
    authorization: TransferAuthorization,
    seller_address: Address,
) -> Result<String> {
    // 1. Verify signature
    let valid = verify_eip3009_signature(&authorization, chain).await?;
    if !valid {
        return Err("Invalid signature");
    }

    // 2. Verify amount matches expected price
    let expected_amount = get_tier_price(request.tier, chain);
    if authorization.value != expected_amount {
        return Err("Incorrect payment amount");
    }

    // 3. Execute on-chain
    let usdc_contract = get_usdc_contract(chain);
    let tx_hash = usdc_contract
        .method::<_, H256>("transferWithAuthorization", (
            authorization.from,
            authorization.to,
            authorization.value,
            authorization.valid_after,
            authorization.valid_before,
            authorization.nonce,
            authorization.v,
            authorization.r,
            authorization.s,
        ))?
        .send()
        .await?
        .await?
        .unwrap();

    Ok(format!("0x{:x}", tx_hash))
}
```

**Client-side payment signing:**

```typescript
// TypeScript (ethers.js)
import { ethers } from 'ethers';

async function signUsdcPayment(
  amount: string,
  sellerAddress: string,
  chain: 'avalanche' | 'base' | 'polygon'
) {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const userAddress = await signer.getAddress();

  const usdcAddress = USDC_ADDRESSES[chain];
  const nonce = ethers.utils.randomBytes(32);
  const validAfter = 0;
  const validBefore = Math.floor(Date.now() / 1000) + 3600; // 1 hour

  const domain = {
    name: 'USD Coin',
    version: '2',
    chainId: CHAIN_IDS[chain],
    verifyingContract: usdcAddress,
  };

  const types = {
    TransferWithAuthorization: [
      { name: 'from', type: 'address' },
      { name: 'to', type: 'address' },
      { name: 'value', type: 'uint256' },
      { name: 'validAfter', type: 'uint256' },
      { name: 'validBefore', type: 'uint256' },
      { name: 'nonce', type: 'bytes32' },
    ],
  };

  const value = {
    from: userAddress,
    to: sellerAddress,
    value: ethers.utils.parseUnits(amount, 6), // USDC has 6 decimals
    validAfter,
    validBefore,
    nonce: ethers.utils.hexlify(nonce),
  };

  const signature = await signer._signTypedData(domain, types, value);
  const { v, r, s } = ethers.utils.splitSignature(signature);

  return {
    from: userAddress,
    to: sellerAddress,
    value: value.value.toString(),
    validAfter,
    validBefore,
    nonce: ethers.utils.hexlify(nonce),
    v,
    r,
    s,
  };
}
```

### Pricing in USDC

**Tier pricing (stable USD values):**

```rust
pub fn tier_price_usdc(tier: Tier) -> U256 {
    // USDC has 6 decimals (not 18 like GLUE/ETH)
    match tier {
        Tier::Basic => U256::from(200_000),      // 0.20 USDC
        Tier::Standard => U256::from(1_000_000), // 1.00 USDC
        Tier::Pro => U256::from(5_000_000),      // 5.00 USDC
        Tier::Enterprise => U256::from(20_000_000), // 20.00 USDC
    }
}
```

**Advantages of USDC pricing:**
- ✅ **Predictable costs** - $0.20/month is always $0.20/month
- ✅ **No volatility risk** - Users can budget accurately
- ✅ **Enterprise-friendly** - Finance teams understand $X/month

**Disadvantage:**
- ❌ **No upside** - If GLUE 100x, Karmacadabra agents earn more. USDC stays $1.

**Mitigation:** Lighthouse is separate business, not tied to GLUE success. Stability > speculation.

---

## 🌪️ ChaosChain Integration (Research)

### What is ChaosChain?

**From research:** ChaosChain is an **experimental Layer 2 blockchain** where:
- Traditional consensus rules are replaced by AI agents
- Blocks validated by AI agents with distinct personalities
- State transitions are arbitrary (no fixed rules)
- Governance influenced by memes and social dynamics

**Philosophy:** "True decentralization comes from systems that embrace chaos and uncertainty."

### Relevance to Lighthouse

**Potential use cases:**

**1. Chaos Engineering for Monitoring**

Test Lighthouse's resilience by simulating failures:

```javascript
{
  "chaos_test": {
    "name": "Facilitator Downtime Simulation",
    "steps": [
      {
        "action": "baseline",
        "monitor": "https://facilitator.xyz/health",
        "duration": "5m"
      },
      {
        "action": "inject_failure",
        "target": "facilitator.xyz",
        "failure_type": "network_partition",
        "duration": "2m"
      },
      {
        "action": "verify_alert",
        "expected_alert": "downtime",
        "max_detection_time": "30s"
      },
      {
        "action": "restore",
        "target": "facilitator.xyz"
      },
      {
        "action": "verify_recovery",
        "expected_alert": "recovery",
        "max_detection_time": "30s"
      }
    ]
  }
}
```

**2. AI Agent Consensus for Anomaly Detection**

Use ChaosChain AI agents to validate anomalies:

```
Lighthouse detects: "Facilitator response time increased 300%"
↓
Submit to ChaosChain agents:
  - Agent A (Conservative): "This is normal traffic spike"
  - Agent B (Paranoid): "This is a DDoS attack"
  - Agent C (Optimistic): "Performance optimization in progress"
↓
Consensus: 2/3 agents say "investigate" → Send critical alert
```

**3. Chaos Testing as a Service (Lighthouse Pro Feature)**

Offer chaos engineering:

```javascript
POST /chaos/test
{
  "target": "https://myapp.com",
  "scenarios": [
    "high_latency",
    "intermittent_503",
    "certificate_expiration",
    "ddos_simulation"
  ],
  "duration": "1h",
  "report": true
}
```

**Pricing:** 5.00 USDC per chaos test (Pro tier)

### Integration Strategy

**Phase 1 (Foundational):** Build Lighthouse without ChaosChain
**Phase 2 (Research):** Investigate ChaosChain APIs, stability
**Phase 3 (Pilot):** Integrate chaos testing for Lighthouse's own monitoring
**Phase 4 (Product):** Offer chaos testing as premium feature

**Risk assessment:**
- ⚠️ ChaosChain is **experimental** - may be unstable
- ⚠️ "Arbitrary state transitions" could break integrations
- ⚠️ AI agent consensus may be slow/expensive

**Recommendation:** **Monitor ChaosChain development, defer integration to Phase 4+** (after Lighthouse is stable and profitable).

**Alternative:** Use traditional chaos engineering tools (Chaos Toolkit, LitmusChaos) instead of ChaosChain.

---

## ☁️ EigenCloud Deployment (Research)

### What is EigenCloud?

**From research (October 2025):**

**EigenCloud** is a developer platform for **verifiable infrastructure**:
- Extends blockchain trust to off-chain applications
- Bundles EigenDA (data availability), EigenCompute (secure execution), EigenAI (verifiable inference)
- Backed by **$20B+ in staked assets** (restaking via EigenLayer)
- **190+ AVSs** (Autonomous Verifiable Services) in development, 40+ live on mainnet

**EigenAI breakthrough:** Deterministic LLM inference (makes AI model outputs verifiable)

**Recent adoption:** Google Cloud adopted EigenCloud in October 2025 for AI agent payments via AP2 protocol.

### Relevance to Lighthouse

**Potential benefits:**

**1. Verifiable Monitoring**
- Lighthouse checks are recorded on-chain via EigenDA
- Users can verify: "Did Lighthouse actually check my service at 10:00 AM?"
- Trustless audit trail (can't fake monitoring data)

**2. Decentralized Compute**
- Run Lighthouse monitoring checks on EigenCompute (not centralized AWS)
- Verifiable execution: Prove that checks were executed correctly

**3. AI-Powered Analysis (Future)**
- Use EigenAI for incident root cause analysis
- Verifiable AI results (reproducible, auditable)

**4. Restaking Economics**
- Lighthouse could become an AVS (Autonomous Verifiable Service)
- Earn restaking rewards from EigenLayer operators

### Deployment Comparison

| Aspect | AWS EC2 (Recommended) | EigenCloud | AWS RDS Multi-AZ |
|--------|----------------------|------------|------------------|
| **Database Cost (3yr)** | **$1,230** | ❌ NOT suitable for DB | $2,609 |
| **Backend Cost** | $8-72/month | **$5-20/month (40-50% cheaper)** | N/A |
| **Database Performance** | <1ms latency | ❌ 50-200ms (10-15x slower) | <1ms latency |
| **Storage Reliability** | EBS (99.999%) | Filecoin (varies) | EBS Multi-AZ |
| **Trust Model** | Centralized | **Decentralized (restaked ETH)** | Centralized |
| **Verifiability** | None | **On-chain proofs** | None |
| **Self-Hosting** | ✅ Docker ready | Limited | ❌ AWS-only |
| **Uptime SLA** | 99.95% | None (best-effort) | 99.95% |

**Key Finding (from terraform-specialist research):**
- ✅ **Use EigenCloud for stateless backend compute** (40-50% cost savings)
- ❌ **DO NOT use EigenCloud for PostgreSQL/TimescaleDB** (storage too slow, 10-15x latency)
- ✅ **Hybrid approach:** Backend on EigenCloud + Database on AWS EC2/RDS

**See detailed analysis:** `lighthouse/TIMESCALEDB-AWS-DEPLOYMENT-ARCHITECTURE.md`

### Research Action Items

**1. Technical Feasibility:**
- [x] **COMPLETED** - terraform-specialist research findings:
  - ✅ EigenCloud suitable for **backend compute only** (40-50% cost savings)
  - ❌ EigenCloud **NOT suitable for databases** (50-200ms storage latency)
  - ✅ Pricing: $5-20/month for backend vs $8-72/month AWS EC2
  - ❌ Database latency: 10-15x slower than AWS EBS
- [ ] Test deployment: Deploy backend on EigenCloud, DB on AWS EC2
- [ ] Benchmark: Cross-cloud latency (EigenCloud backend → AWS DB)

**2. Verifiability Benefits:**
- [ ] Assess: Do Lighthouse users value on-chain proofs?
- [ ] Compare: Verifiable monitoring vs traditional monitoring (value prop)
- [ ] Implementation: How much work to integrate EigenDA?

**3. AVS Economics:**
- [ ] Research: Can Lighthouse become an EigenLayer AVS?
- [ ] Calculate: Restaking rewards vs hosting costs
- [ ] Compliance: Legal/regulatory implications of AVS status

**4. Risk Assessment:**
- [ ] Stability: Is EigenCloud production-ready or beta?
- [ ] Downtime: What's EigenCloud's uptime SLA?
- [ ] Lock-in: Can we migrate off EigenCloud easily?

### Deployment Strategy (Updated - Based on Research)

**Phase 1 (MVP - Month 1-3):** Deploy on **AWS EC2 t4g.micro**
- Database: TimescaleDB on EC2 + persistent EBS volume ($8/month)
- Backend: Co-located on same EC2 instance (simplest architecture)
- Cost: **$97/year** (vs $2,609/year RDS)
- Automated daily backups via AWS Backup (EBS snapshots)

**Phase 2 (Growth - Month 4-12):** Scale **AWS EC2 t4g.small**
- Database: Separate EC2 t4g.small + 100GB EBS ($22/month)
- Backend: 2x t4g.small instances + load balancer ($45/month total)
- Cost: **$263/year database** + backend compute
- Terraform deployment (`lighthouse/terraform/environments/prod`)

**Phase 3 (Optional - Hybrid Cloud - Month 6+):**
- **Backend:** Migrate to EigenCloud (40-50% cost savings, verifiable compute)
- **Database:** Keep on AWS EC2/RDS (cannot use EigenCloud for DB)
- **Challenge:** Cross-cloud latency (EigenCloud → AWS database)
- **Benefit:** Decentralized compute + verifiable monitoring proofs

**Phase 4 (Scale - Year 2+):** Migrate to **AWS RDS Multi-AZ**
- **Trigger:** Revenue > $5,000/month OR team has <5 hours/month for ops
- Database: RDS db.t4g.medium Multi-AZ ($165/month)
- Cost: **$1,982/year** (justified by zero ops overhead)
- Zero-downtime migration via AWS DMS

**Recommendation:** **Start on AWS EC2 ($8/month), evaluate EigenCloud for backend only (NOT database).**

**Rationale:**
- ✅ **Cost optimized:** Save $1,379 over 3 years vs RDS
- ✅ **Multi-cloud ready:** Docker + Terraform = portable
- ✅ **EigenCloud for compute only:** 40-50% savings, but NOT for database (too slow)
- ✅ **Clear migration path:** EC2 → RDS when ops burden exceeds cost savings
- ✅ **Production-ready today:** Complete Terraform modules in `lighthouse/terraform/`

---

## 💵 Pricing Strategy

### Competitive Analysis

**Existing Services (2025 data):**

| Service | Check Frequency | Price/Month | Monitors | Features |
|---------|----------------|-------------|----------|----------|
| **AWS CloudWatch Synthetics** | 5 min | **$51.84** | 1 canary | Multi-step flows, screenshots |
| **Datadog Synthetic Monitoring** | 1 min | **$5.00** | 1 test | API + browser tests |
| **Pingdom** | 1 min | **$15.00** | 10 monitors | Uptime, transaction, real user monitoring |
| **UptimeRobot** | 5 min | **$7.00** | 50 monitors | HTTP, keyword, port monitoring |
| **Better Uptime** | 30 sec | **$20.00** | 10 monitors | Incident management, status pages |
| **StatusCake** | 5 min | **$25.00** | Unlimited | Performance, uptime, domain monitoring |

**Cost calculation example (AWS Synthetics):**
- 1 canary × 12 runs/hour × 24 hours × 31 days = **8,928 runs**
- 8,928 × $0.0012 = **$10.71** (canary runs only)
- + Lambda execution (~$5/month)
- + S3 storage for screenshots (~$2/month)
- + CloudWatch Logs (~$3/month)
- **Total: ~$20-25/month** for 5-min checks

**Why are they expensive?**
- Credit card processing fees (3%)
- Enterprise sales teams (high CAC)
- VC-backed growth expectations (need 10x returns)
- Centralized infrastructure costs

### Lighthouse Pricing (USDC-based)

**Philosophy:** **50x cheaper than AWS Synthetics, 10x cheaper than competitors**

| Tier | Check Frequency | Endpoints | Canary Flows | Channels | Price (USDC) | Equivalent AWS Cost | Savings |
|------|----------------|-----------|--------------|----------|--------------|---------------------|---------|
| **Free** | 1 hour | 1 | 0 | Discord only | **$0.00** | $0.86/month | 100% |
| **Basic** | 15 min | 3 | 0 | Discord, Telegram | **$0.20** | $3.46/month | **94%** |
| **Standard** | 5 min | 10 | 3 | All (no SMS) | **$1.00** | $10.37/month | **90%** |
| **Pro** | 1 min | 50 | 10 | All + SMS | **$5.00** | $51.84/month | **90%** |
| **Enterprise** | 30 sec | Unlimited | Unlimited | All + Custom | **$20.00** | $103.68/month | **81%** |

**Additional features by tier:**

| Feature | Free | Basic | Standard | Pro | Enterprise |
|---------|------|-------|----------|-----|------------|
| **HTTP monitoring** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Custom status codes** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Response time tracking** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Canary flows** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **Blockchain balance monitoring** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **WebSocket monitoring** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **GraphQL monitoring** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Smart contract monitoring** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Chaos testing** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Data retention** | 7 days | 7 days | 30 days | 90 days | 365 days |
| **API access** | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Status page** | ❌ | ❌ | ✅ | ✅ | ✅ |
| **White-label** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **SLA** | None | None | 99% | 99.9% | 99.99% |

**Pay-per-use (One-time checks):**
- Single check: **0.001 USDC** (~$0.001)
- 100 checks: **0.05 USDC** (~$0.05)
- 1000 checks: **0.30 USDC** (~$0.30)

**Use case:** CI/CD integration (check staging deployment before promoting to prod)

### Why 50x Cheaper?

**1. No Payment Processing Fees**
- AWS/Datadog: 3% Stripe fee + PCI compliance costs
- Lighthouse: 0% (USDC on-chain, $0.10 gas per transaction)
- **Savings: 3% of revenue**

**2. Crypto-Native Efficiency**
- No credit card fraud chargebacks
- No payment disputes (on-chain = final)
- No KYC/AML overhead (crypto wallet = identity)

**3. Open-Source + Community**
- No VC pressure for 10x returns
- Community contributions (features built by users)
- Transparent pricing (no enterprise sales negotiations)

**4. Efficient Infrastructure**
- Rust backend (10x lower memory usage than competitors' Python/Ruby)
- TimescaleDB compression (10x storage savings)
- Multi-cloud strategy (choose cheapest provider)

**5. Self-Hosted Option**
- Large customers can self-host (Docker Compose)
- We provide support, not infrastructure
- **Revenue from support, not hosting**

### Revenue Projections

**Operating Costs (Monthly):**

| Resource | Cost (AWS) | Cost (EigenCloud) | Cost (Self-Hosted) |
|----------|-----------|-------------------|-------------------|
| Compute (2 vCPU, 4GB RAM) | $30 | **$15** (estimated) | $0 (user's infra) |
| TimescaleDB (EC2) | $8 | $22 | $0 (self-hosted) |
| Redis (256MB) | $15 | $10 (estimated) | $0 (user's Redis) |
| Bandwidth (50GB out) | $5 | $5 | $0 |
| Domain + SSL | $2 | $2 | $0 |
| **Total** | **$77** | **$57** (estimated) | **$0** |

**Break-Even Analysis:**

**Scenario 1: AWS Deployment**
- Operating costs: $77/month
- Average tier: Standard ($1.00 USDC)
- **Break-even: 77 subscribers**

**Scenario 2: EigenCloud Deployment**
- Operating costs: $57/month
- Average tier: Standard ($1.00 USDC)
- **Break-even: 57 subscribers**

**Scenario 3: Freemium Model**
- Free tier: 60% of users (0 revenue)
- Paid tier: 40% of users (avg $1.50 USDC)
- **Break-even: 128 total users (51 paid)**

### Growth Projections

**Conservative (Year 1):**

| Quarter | Total Users | Paid Users | Avg Price | Revenue | Costs | Net |
|---------|------------|------------|-----------|---------|-------|-----|
| Q1 | 100 | 20 | $0.50 | $10 | $77 | **-$67** |
| Q2 | 300 | 80 | $0.75 | $60 | $77 | **-$17** |
| Q3 | 600 | 180 | $1.00 | $180 | $77 | **+$103** |
| Q4 | 1000 | 350 | $1.25 | $438 | $77 | **+$361** |

**Cumulative Year 1:** +$380 profit

**Moderate (Year 1):**

| Quarter | Total Users | Paid Users | Avg Price | Revenue | Costs | Net |
|---------|------------|------------|-----------|---------|-------|-----|
| Q1 | 200 | 50 | $0.50 | $25 | $77 | **-$52** |
| Q2 | 600 | 180 | $1.00 | $180 | $77 | **+$103** |
| Q3 | 1500 | 500 | $1.50 | $750 | $77 | **+$673** |
| Q4 | 3000 | 1000 | $2.00 | $2000 | $77 | **+$1923** |

**Cumulative Year 1:** +$2,647 profit

**Aggressive (Year 1):**

| Quarter | Total Users | Paid Users | Avg Price | Revenue | Costs | Net |
|---------|------------|------------|-----------|---------|-------|-----|
| Q1 | 500 | 120 | $0.75 | $90 | $77 | **+$13** |
| Q2 | 1500 | 450 | $1.25 | $563 | $77 | **+$486** |
| Q3 | 4000 | 1200 | $2.00 | $2400 | $77 | **+$2323** |
| Q4 | 10000 | 3000 | $3.00 | $9000 | $77 | **+$8923** |

**Cumulative Year 1:** +$11,745 profit

**Key assumptions:**
- 30-40% conversion rate (free → paid)
- Average price increases as users upgrade tiers
- Operating costs stay flat (scale with TimescaleDB compression, not more servers)

### Pricing Justification (Marketing Angle)

**Tagline:** *"AWS Synthetics, 50x cheaper, for Web3"*

**Comparison chart (for landing page):**

```
AWS CloudWatch Synthetics:  💰💰💰💰💰 $51.84/month
Datadog Synthetics:         💰💰💰💰💰 $5.00/month
Pingdom:                    💰💰💰💰💰 $15.00/month
UptimeRobot:                💰💰💰     $7.00/month

Lighthouse Pro:             💰         $5.00/month  ⚡ 10x cheaper
Lighthouse Standard:        💰         $1.00/month  ⚡ 50x cheaper
```

**Value propositions:**
- **For crypto projects:** "Pay with USDC, monitor smart contracts, 10x savings"
- **For DevOps teams:** "AWS Synthetics features without AWS prices"
- **For startups:** "Free tier → your first 100 users cost $0"

---

## 🗓️ Implementation Roadmap

### Phase 1: MVP (2 Weeks)

**Goal:** HTTP monitoring + Discord alerts + USDC payments

**Week 1:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | Project setup, Rust backend skeleton | `lighthouse/backend/src/main.rs` |
| Tue | PostgreSQL schema, TimescaleDB hypertables | `lighthouse/backend/migrations/*.sql` + `src/db/` |
| Wed | HTTP health checker (reqwest) | `lighthouse/backend/src/monitors/http.rs` |
| Thu | Scheduler (tokio background task) | `lighthouse/backend/src/scheduler.rs` |
| Fri | Discord alert integration | `lighthouse/backend/src/alerts/discord.rs` |

**Week 2:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | USDC payment verification (Avalanche Fuji) | `lighthouse/backend/src/payments/usdc.rs` |
| Tue | x402 protocol integration | `lighthouse/backend/src/payments/x402.rs` |
| Wed | API endpoints (POST /subscribe, GET /metrics) | `lighthouse/backend/src/api/` |
| Thu | Docker Compose deployment | `lighthouse/docker-compose.yml` |
| Fri | Testing + docs (README.md, README.es.md) | Documentation |

**MVP Features:**
- ✅ HTTP endpoint monitoring
- ✅ Custom status codes (200, 201, 202, etc)
- ✅ Response time tracking
- ✅ Discord alerts (downtime + recovery)
- ✅ USDC payments (Avalanche Fuji)
- ✅ Basic tier (15-min checks)
- ✅ API: POST /subscribe, GET /metrics
- ✅ Bilingual docs (English + Spanish)

**MVP Endpoints:**
```
POST   /subscribe          # Create subscription (USDC payment)
GET    /subscriptions/:id  # Get subscription status
DELETE /subscriptions/:id  # Cancel subscription
GET    /metrics/:id        # Get uptime metrics
GET    /health             # Lighthouse health check
GET    /.well-known/agent-card  # Optional (if integrating with Karmacadabra)
```

**Deployment:** AWS ECS Fargate (known technology, fast deployment)

### Phase 2: Canary Flows (2 Weeks)

**Goal:** Multi-step scenarios (AWS Synthetics equivalent)

**Week 3:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | Canary flow parser (JSON schema) | `lighthouse/backend/src/canary/parser.rs` |
| Tue | Step orchestrator (variable extraction) | `lighthouse/backend/src/canary/executor.rs` |
| Wed | HTTP step handler (with context variables) | `lighthouse/backend/src/canary/steps/http.rs` |
| Thu | Python worker integration (Celery) | `lighthouse/workers/canary_worker.py` |
| Fri | Playwright setup (browser automation) | `lighthouse/workers/browser.py` |

**Week 4:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | Screenshot on failure | `lighthouse/workers/screenshot.py` |
| Tue | Timing breakdown per step | `lighthouse/backend/src/canary/timing.rs` |
| Wed | Canary flow API endpoints | POST /canaries, GET /canaries/:id/results |
| Thu | Standard tier implementation (5-min checks) | Tier upgrade logic |
| Fri | Testing + docs (CANARY_GUIDE.md) | Documentation |

**Phase 2 Features:**
- ✅ Multi-step canary flows
- ✅ Variable extraction (step N → step N+1)
- ✅ Custom scripts (Python workers)
- ✅ Screenshot on failure (Playwright)
- ✅ Step-by-step timing breakdown
- ✅ Standard tier (5-min checks, 10 endpoints)

### Phase 3: Blockchain Monitoring (1 Week)

**Goal:** Native token balance monitoring (AVAX, ETH, MATIC)

**Week 5:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | Blockchain RPC client (alloy-rs) | `lighthouse/backend/src/blockchain/client.rs` |
| Tue | Native balance checker | `lighthouse/backend/src/monitors/balance.rs` |
| Wed | Multi-chain support (Avalanche, Base, Polygon) | Chain configurations |
| Thu | Balance alert thresholds | Alert logic |
| Fri | Testing + docs | Documentation update |

**Phase 3 Features:**
- ✅ Native token balance monitoring (AVAX, ETH, MATIC)
- ✅ Multi-chain support (Avalanche, Base, Polygon)
- ✅ Alert thresholds (warning + critical)
- ✅ Pro tier (1-min checks, 50 endpoints)

### Phase 4: Research & Advanced (2 Weeks)

**Goal:** Evaluate EigenCloud, explore ChaosChain

**Week 6:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | EigenCloud research (docs, pricing, stability) | Research doc |
| Tue | EigenCloud test deployment (parallel with AWS) | Deployment scripts |
| Wed | Benchmark: AWS vs EigenCloud (latency, cost) | Benchmark report |
| Thu | ChaosChain research (APIs, use cases) | Research doc |
| Fri | Decision: Migrate to EigenCloud or stay on AWS? | Architecture decision |

**Week 7:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | Telegram bot API integration | `lighthouse/backend/src/alerts/telegram.rs` |
| Tue | Email alerts (SMTP) | `lighthouse/backend/src/alerts/email.rs` |
| Wed | SMS alerts (Twilio, Pro tier only) | `lighthouse/backend/src/alerts/sms.rs` |
| Thu | Multi-chain USDC support (Base, Polygon) | Payment support |
| Fri | Testing + docs | Documentation update |

**Phase 4 Features:**
- ✅ EigenCloud evaluation (parallel deployment)
- ✅ ChaosChain research (defer integration to Phase 5+)
- ✅ Multi-channel alerts (Discord, Telegram, Email, SMS)
- ✅ Multi-chain USDC (Avalanche, Base, Polygon testnets)

### Phase 5: Polish & Launch (1 Week)

**Goal:** Public launch, marketing, onboard first customers

**Week 8:**

| Day | Task | Deliverable |
|-----|------|-------------|
| Mon | Landing page (bilingual, pricing table) | `lighthouse/frontend/` |
| Tue | Public status page (uptime badges) | Status page generator |
| Wed | Documentation polish (guides, API docs) | `lighthouse/docs/` |
| Thu | Marketing materials (blog post, Twitter thread) | Marketing content |
| Fri | **Public launch** 🚀 | Announce to Web3 communities |

**Launch Checklist:**
- [ ] Landing page (English + Spanish)
- [ ] Pricing page (comparison chart)
- [ ] Documentation (quickstart, API reference, guides)
- [ ] Public status page (show Lighthouse monitoring itself)
- [ ] Blog post: "Introducing Lighthouse: AWS Synthetics for Web3"
- [ ] Twitter thread (Ultravioleta DAO account)
- [ ] Post to: r/ethereum, r/web3, r/devops, crypto Discord servers
- [ ] Onboard first 10 customers (Karmacadabra agents + external)

**Launch Metrics to Track:**
- Signups (total users)
- Conversion rate (free → paid)
- Revenue (USDC collected)
- Endpoints monitored (usage)
- Alert delivery success rate (reliability)

### Post-Launch Roadmap

**Phase 6 (Month 2-3): Scale**
- GraphQL monitoring
- WebSocket monitoring
- Smart contract state monitoring
- White-label option (Enterprise tier)
- Self-hosted deployment guide

**Phase 7 (Month 4-6): Advanced Features**
- AI-powered incident analysis (CrewAI integration)
- Predictive alerts (ML models)
- Chaos testing integration (ChaosChain or Chaos Toolkit)
- Status page widgets (embed in README)

**Phase 8 (Month 7-12): Ecosystem Growth**
- Lighthouse SDK (TypeScript, Python, Rust)
- CI/CD integrations (GitHub Actions, GitLab CI)
- Terraform provider
- API clients for major languages
- Community plugins (custom monitors)

---

## 🚀 Deployment Guide

### Quick Start

**For complete step-by-step instructions, see:** [`DEPLOYMENT-STEP-BY-STEP.md`](./DEPLOYMENT-STEP-BY-STEP.md)

### Deployment Options Summary

| Option | Database | Backend | Cost | Maturity | Best For |
|--------|----------|---------|------|----------|----------|
| **A. Local Dev** | Docker TimescaleDB | Docker Rust | $0 | ✅ Ready | Development & testing |
| **B. AWS Prod** | EC2 + EBS | EC2/Fargate | $8-72/mo | ✅ Ready | Production MVP |
| **C. EigenCloud Hybrid** | AWS EC2 | EigenCloud TEE | $5-50/mo | ⚠️ Alpha | Research only (Q3 2025) |

### Option A: Local Development (30 min)

```bash
# 1. Clone repository
git clone https://github.com/ultravioletadao/karmacadabra.git
cd karmacadabra/lighthouse

# 2. Create .env file
cp .env.example .env

# 3. Start services
docker-compose up -d

# 4. Verify
curl http://localhost:8080/health
# Expected: {"status":"ok","database":"connected"}

# 5. Run migrations
docker exec -it lighthouse-backend sqlx migrate run

# 6. Test monitoring
curl -X POST http://localhost:8080/subscribe \
  -H "Content-Type: application/json" \
  -d '{"target_type":"http","target_config":{"url":"https://google.com"}}'
```

**See full guide:** [Local Development (Docker Compose)](./DEPLOYMENT-STEP-BY-STEP.md#option-a-local-development-docker-compose)

---

### Option B: AWS Production (60 min)

```bash
# 1. Configure AWS CLI
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1)

# 2. Create SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/lighthouse-aws
aws ec2 import-key-pair --key-name lighthouse-prod \
  --public-key-material fileb://~/.ssh/lighthouse-aws.pub

# 3. Deploy infrastructure with Terraform
cd lighthouse/terraform/environments/prod
terraform init
terraform plan  # Review: 23 resources, ~$22/month
terraform apply

# 4. Verify deployment
terraform output database_endpoint
# Output: 10.0.2.123:5432

# 5. SSH to instance
ssh -i ~/.ssh/lighthouse-aws ec2-user@$(terraform output -raw bastion_public_ip)

# 6. Verify TimescaleDB running
docker ps
docker logs timescaledb
```

**Cost:** $8/month (t4g.micro MVP) → $22/month (t4g.small growth) → $72/month (t4g.medium scale)

**See full guide:** [AWS Production (Terraform)](./DEPLOYMENT-STEP-BY-STEP.md#option-b-aws-production-terraform)

---

### Option C: EigenCloud Hybrid (Research Phase)

**⚠️ WARNING: NOT READY FOR PRODUCTION**

**Current Status (October 2025):**
- EigenCompute: **Mainnet ALPHA** (Q3 2025)
- Documentation: Partially blocked/incomplete
- Terraform/SDK: **NOT available** (CLI only)
- **Critical finding:** Cannot run databases (storage latency 50-200ms, 10-15x slower than AWS EBS)

**Recommendation:**
- ❌ **DO NOT use for Phase 1 MVP**
- ✅ **Research in Phase 4 (Week 6)** - Deploy backend only, keep database on AWS
- 🔄 **Re-evaluate Q4 2025** when EigenCompute exits alpha

**Research Plan:**
1. Access docs.eigencloud.xyz (request access if needed)
2. Install EigenCloud CLI (method TBD)
3. Deploy test backend with Docker image
4. Benchmark cross-cloud latency (EigenCloud → AWS database)
5. Cost analysis (actual vs projected savings)
6. Verifiability testing (on-chain proof validation)
7. Go/No-Go decision based on weighted scoring

**See full research plan:** [EigenCloud Hybrid (Research)](./DEPLOYMENT-STEP-BY-STEP.md#option-c-eigencloud-hybrid-research)

---

### EigenCloud Research Findings (October 2025)

**What We Know:**
- ✅ EigenCompute supports Docker deployment (Rust backend compatible)
- ✅ CLI-based workflow (no Terraform provider yet)
- ✅ Pricing: 40-50% cheaper than AWS EC2 for compute
- ✅ Verifiable execution via TEE (Trusted Execution Environment)
- ✅ On-chain proofs via EigenDA

**Critical Limitations:**
- ❌ **No persistent storage for databases** - EigenDA is "short-term storage" (data availability, not block storage)
- ❌ **Storage latency 50-200ms** - 10-15x slower than AWS EBS (<1ms)
- ❌ **Alpha stage** - Mainnet alpha, stability unknown
- ❌ **Limited documentation** - docs.eigencloud.xyz access restricted
- ❌ **Unknown pricing finalization** - Alpha pricing may change

**Hybrid Architecture (If Pursuing):**
```
Backend: EigenCloud (40-50% cost savings, verifiable compute)
   ↓ (Cross-cloud network: 50-200ms latency)
Database: AWS EC2 TimescaleDB (cannot move to EigenCloud)
```

**Decision Matrix:**
```
Use EigenCloud IF:
- Cost savings > 40% AND
- Verifiability is critical feature AND
- Cross-cloud latency acceptable (<100ms) AND
- Platform exits alpha to beta/prod

Stay on AWS IF:
- MVP launch is priority OR
- Cannot tolerate alpha platform risk OR
- Cross-cloud latency degrades UX OR
- Documentation insufficient for production
```

**Next Steps:**
- Week 6 (Phase 4): Allocate 1 week for hands-on EigenCloud research
- Document findings in `lighthouse/research/eigencloud-decision.md`
- Update master plan with go/no-go decision

---

### Deployment Checklist (MVP Launch)

**Pre-deployment:**
- [ ] AWS account created and configured
- [ ] SSH key pair generated and imported
- [ ] Domain registered (`lighthouse.ultravioletadao.xyz`)
- [ ] .env file configured with secrets
- [ ] USDC contract addresses verified (Fuji testnet)
- [ ] Discord webhook URL for alerts
- [ ] Terraform variables reviewed (`terraform.tfvars`)

**Deployment:**
- [ ] `terraform init` successful
- [ ] `terraform plan` reviewed (cost estimate acceptable)
- [ ] `terraform apply` completed
- [ ] Database endpoint accessible
- [ ] SSH access verified
- [ ] TimescaleDB running (`docker ps`)
- [ ] Migrations applied (`sqlx migrate run`)
- [ ] Health check returns OK (`curl /health`)

**Post-deployment:**
- [ ] CloudWatch dashboard configured
- [ ] SNS email alerts subscribed
- [ ] Backup plan verified (daily EBS snapshots)
- [ ] First test subscription created
- [ ] Monitoring check executed successfully
- [ ] Discord alert received
- [ ] Metrics visible in `hourly_metrics` view
- [ ] Documentation updated with endpoints

**Production ready when:**
- ✅ All checklist items completed
- ✅ 24 hours uptime without errors
- ✅ Test subscription runs checks successfully
- ✅ Alerts delivered to Discord
- ✅ Database compression active (check `pg_stat_compression`)
- ✅ Terraform state backed up (`terraform state pull`)

---

## 💼 Business Model

### Target Customers

**1. Web3 Infrastructure Providers (Primary)**

**Examples:**
- RPC providers (Alchemy, Infura alternatives)
- Indexers (The Graph nodes)
- Oracles (Chainlink nodes)
- Bridges (cross-chain infrastructure)

**Pain:** Downtime = lost revenue + reputation damage
**Value:** Crypto-native monitoring + blockchain-specific checks
**ARPU:** $5-20/month (Pro/Enterprise tiers)

**2. DeFi Protocols**

**Examples:**
- DEXs (Uniswap forks)
- Lending protocols (Aave forks)
- Yield aggregators
- Stablecoin issuers

**Pain:** Smart contract failures, oracle issues, frontend downtime
**Value:** Monitor contracts + frontends + APIs in one place
**ARPU:** $1-5/month (Standard/Pro tiers)

**3. NFT Platforms**

**Examples:**
- NFT marketplaces
- Generative art platforms
- Gaming projects (NFT-based)

**Pain:** Mint failures, IPFS gateway issues, metadata API downtime
**Value:** Monitor metadata APIs + IPFS gateways + minting contracts
**ARPU:** $1-5/month (Standard/Pro tiers)

**4. DAOs**

**Examples:**
- UltravioletaDAO (first customer)
- Other governance DAOs
- Protocol DAOs

**Pain:** Governance frontend downtime, snapshot failures, treasury monitoring
**Value:** Monitor DAO infrastructure + treasury balances + proposal systems
**ARPU:** $1-5/month (Standard tier)

**5. Traditional Web Apps (Secondary)**

**Examples:**
- SaaS companies willing to pay with crypto
- Privacy-focused apps
- International teams (crypto is easier than international credit cards)

**Pain:** Same as Web3 projects, but less crypto-specific
**Value:** 50x cheaper than AWS Synthetics
**ARPU:** $1-5/month (Standard/Pro tiers)

### Customer Acquisition Strategy

**Phase 1 (Month 1-2): Karmacadabra Ecosystem**
- Onboard 5 system agents (validator, karma-hello, abracadabra, skill-extractor, voice-extractor)
- Onboard 10 user agents (48 total, start with most active)
- **Goal: 15 customers, prove product-market fit**

**Phase 2 (Month 3-4): Web3 Communities**
- Post to:
  - r/ethereum, r/web3, r/cryptocurrency
  - Ethereum Magicians forum
  - Discord: EthStaker, DeFi, Web3 DevOps
- Write blog posts:
  - "How to Monitor Your DeFi Protocol for $1/month"
  - "AWS Synthetics Alternative for Web3 Developers"
- **Goal: 100 customers**

**Phase 3 (Month 5-6): Partnerships**
- Integrate with:
  - Alchemy (RPC monitoring)
  - The Graph (indexer monitoring)
  - Chainlink (oracle monitoring)
- Offer:
  - White-label option (they rebrand Lighthouse)
  - Affiliate program (20% revenue share)
- **Goal: 500 customers**

**Phase 4 (Month 7-12): Enterprise Sales**
- Reach out to:
  - Top 100 DeFi protocols (by TVL)
  - Major NFT platforms
  - Large DAOs (Uniswap, Aave, MakerDAO)
- Offer:
  - Custom SLAs
  - Dedicated support
  - On-premise deployment
- **Goal: 2000+ customers, 10 enterprise deals**

### Revenue Streams

**1. Subscription Revenue (Primary)**
- Free tier: 60% of users, $0 revenue (acquisition funnel)
- Basic tier: 25% of users, $0.20 × 250 = $50/month
- Standard tier: 12% of users, $1.00 × 120 = $120/month
- Pro tier: 2.5% of users, $5.00 × 25 = $125/month
- Enterprise tier: 0.5% of users, $20.00 × 5 = $100/month
- **Total: $395/month at 1000 users**

**2. Pay-Per-Use (Secondary)**
- CI/CD checks: 100 projects × 1000 checks/month × $0.001 = $100/month
- One-time audits: 20 projects × $0.30 = $6/month
- **Total: $106/month**

**3. Premium Features (Future)**
- AI incident analysis: 50 users × 2 incidents × $0.50 = $50/month
- Chaos testing: 10 users × 1 test × $5.00 = $50/month
- Status page widgets: 30 users × $0.10 = $3/month
- **Total: $103/month**

**4. Enterprise Services (Future)**
- White-label licensing: 3 partners × $100/month = $300/month
- Custom integrations: 5 projects × $50/month = $250/month
- On-premise support: 2 enterprises × $500/month = $1000/month
- **Total: $1550/month**

**Total Potential Revenue (at scale):**
- Subscriptions: $395/month
- Pay-per-use: $106/month
- Premium features: $103/month
- Enterprise services: $1550/month
- **Grand Total: $2154/month (~$25,848/year)**

### Profitability Analysis

**Operating Costs (Monthly):**
- EigenCloud (or AWS): $57-77
- Domain + SSL: $2
- Marketing (ads, content): $100
- Support (part-time): $200
- **Total: ~$359-379/month**

**Break-Even:**
- At 1000 users (40% paid, avg $1.50): $600/month revenue
- **Net: +$241/month (profitable)**

**Profitability Timeline:**
- Month 1-2: -$300/month (subsidized by DAO)
- Month 3-4: -$100/month (approaching break-even)
- Month 5-6: +$100/month (profitable)
- Month 7-12: +$500-2000/month (scaling)

### Exit Strategy / Long-Term Vision

**Option 1: Bootstrap to Profitability**
- Self-sustaining SaaS business
- Ultravioleta DAO owns 100%
- Distributes profits to DAO treasury

**Option 2: Spin Out as Separate Entity**
- Lighthouse becomes independent company
- Ultravioleta DAO retains equity stake (e.g., 50%)
- Seek external funding for growth

**Option 3: Acquisition**
- Sell to larger monitoring company (Datadog, New Relic)
- Sell to Web3 infrastructure company (Alchemy, Infura)
- **Estimated valuation at exit:** $500k-2M (based on ARR × 10-20x)

**Recommendation:** **Option 1** (bootstrap), pivot to Option 2/3 if growth requires capital.

---

## 📊 Competitive Analysis

### Direct Competitors

**1. AWS CloudWatch Synthetics**

| Aspect | AWS Synthetics | Lighthouse | Winner |
|--------|---------------|------------|--------|
| **Price** | $51.84/month (5-min) | $1.00/month (5-min) | **Lighthouse (50x)** |
| **Canary Flows** | ✅ Full browser automation | ✅ Playwright equivalent | Tie |
| **Blockchain Monitoring** | ❌ None | ✅ Native token balances | **Lighthouse** |
| **Payment Method** | Credit card | USDC (crypto) | **Lighthouse (Web3)** |
| **Vendor Lock-in** | High (AWS-only) | Low (multi-cloud) | **Lighthouse** |
| **Maturity** | Production (5+ years) | New (unproven) | AWS |

**Target customers:** AWS already has large customers, we target crypto projects + cost-sensitive teams

**2. Datadog Synthetic Monitoring**

| Aspect | Datadog | Lighthouse | Winner |
|--------|---------|------------|--------|
| **Price** | $5/test/month | $1.00/month (10 tests) | **Lighthouse (5x)** |
| **Features** | API + Browser tests | API + Canary flows | Tie |
| **Integrations** | 650+ integrations | 10+ integrations (v1) | Datadog |
| **Blockchain** | ❌ None | ✅ Native support | **Lighthouse** |
| **Self-Hosted** | ❌ SaaS-only | ✅ Docker Compose | **Lighthouse** |

**Target customers:** Crypto projects don't need 650 integrations, they need blockchain monitoring

**3. UptimeRobot**

| Aspect | UptimeRobot | Lighthouse | Winner |
|--------|-------------|------------|--------|
| **Price** | $7/month (50 monitors) | $1/month (10 monitors) | UptimeRobot (better free tier) |
| **Crypto Payments** | ❌ Credit card | ✅ USDC | **Lighthouse** |
| **Canary Flows** | ❌ None | ✅ Multi-step scenarios | **Lighthouse** |
| **Blockchain** | ❌ None | ✅ Smart contracts | **Lighthouse** |
| **Maturity** | 10+ years | New | UptimeRobot |

**Target customers:** UptimeRobot is cheap but basic, we offer advanced features (canary flows) at similar price

### Indirect Competitors

**1. Self-Hosted Solutions**

**Examples:** Prometheus + Grafana, Uptime Kuma, Statping

| Aspect | Self-Hosted | Lighthouse | Winner |
|--------|------------|------------|--------|
| **Price** | $0 (+ hosting) | $1-20/month | Self-Hosted |
| **Maintenance** | DIY (time-consuming) | Managed (zero ops) | **Lighthouse** |
| **Features** | Basic monitoring | Canary flows + blockchain | **Lighthouse** |
| **Payments** | N/A | Crypto-native | **Lighthouse** |

**Target customers:** Teams that value time > money (most startups)

**2. Blockchain-Specific Monitoring**

**Examples:** Blocknative, Tenderly, Alchemy Monitoring

| Aspect | Blocknative | Lighthouse | Winner |
|--------|------------|------------|--------|
| **Focus** | Mempool + transactions | General monitoring + blockchain | Lighthouse (broader) |
| **Price** | $99-499/month | $1-20/month | **Lighthouse (10-50x)** |
| **HTTP Monitoring** | ❌ None | ✅ Full HTTP monitoring | **Lighthouse** |
| **Target** | DeFi traders | Developers + DevOps | **Lighthouse** |

**Target customers:** Most projects need HTTP monitoring + blockchain monitoring, not just blockchain

### Competitive Advantages Summary

**Lighthouse wins on:**
1. **Price:** 10-50x cheaper than incumbents
2. **Crypto-native:** USDC payments, blockchain monitoring built-in
3. **Multi-cloud:** Not locked to AWS/GCP/Azure
4. **Open-source:** Audit code, contribute features, self-host
5. **Web3 focus:** Designed for crypto projects from day 1

**Lighthouse loses on:**
1. **Maturity:** New product, no track record
2. **Integrations:** Fewer integrations than Datadog (650+ vs 10+)
3. **Enterprise sales:** No dedicated sales team (yet)
4. **Brand recognition:** Unknown vs AWS/Datadog

**Strategy:** **Dominate Web3 niche first** (crypto projects need blockchain monitoring + cheap prices), **then expand to general market** (compete on price + features).

---

## 📐 Technical Specifications

### System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Lighthouse Platform                       │
└───────────────────────────────┬──────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            ┌───────▼────────┐     ┌───────▼────────┐
            │  Rust Backend  │     │ Python Workers │
            │  (Axum + Tokio)│     │   (Celery)     │
            └───────┬────────┘     └───────┬────────┘
                    │                       │
        ┌───────────┼───────────┬───────────┼───────────┐
        │           │           │           │           │
   ┌────▼────┐ ┌───▼───┐ ┌────▼────┐ ┌────▼────┐ ┌───▼────┐
   │ HTTP    │ │Balance│ │WebSocket│ │ Canary  │ │Browser │
   │Monitor  │ │Monitor│ │ Monitor │ │Executor │ │ Auto   │
   └────┬────┘ └───┬───┘ └────┬────┘ └────┬────┘ └───┬────┘
        │          │          │            │          │
        └──────────┴──────────┴────────────┴──────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            ┌───────▼────────┐     ┌───────▼────────┐
            │  TimescaleDB   │     │     Redis      │
            │ (Time-Series)  │     │   (Cache)      │
            └───────┬────────┘     └────────────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
   ┌────▼────┐ ┌───▼───┐ ┌────▼────┐ ┌────▼────┐
   │Subscrip │ │Checks │ │Alerts   │ │Metrics  │
   │tions    │ │History│ │         │ │         │
   └─────────┘ └───────┘ └─────────┘ └─────────┘
```

### Folder Structure

```
karmacadabra/lighthouse/            # z:\ultravioleta\dao\karmacadabra\lighthouse\
├── README.md                       # English docs
├── README.es.md                    # Spanish docs
├── ARCHITECTURE.md                 # System design
├── LICENSE                         # Open-source license (Apache 2.0)
├── docker-compose.yml              # Local development
├── docker-compose.prod.yml         # Production deployment
│
├── backend/                        # Rust core
│   ├── Cargo.toml
│   ├── Dockerfile
│   ├── src/
│   │   ├── main.rs                # Entry point
│   │   ├── config.rs              # Configuration loading
│   │   ├── api/                   # HTTP API endpoints
│   │   │   ├── mod.rs
│   │   │   ├── subscribe.rs      # POST /subscribe
│   │   │   ├── metrics.rs        # GET /metrics/:id
│   │   │   └── health.rs         # GET /health
│   │   ├── scheduler/             # Background task scheduler
│   │   │   ├── mod.rs
│   │   │   └── cron.rs           # Tokio cron jobs
│   │   ├── monitors/              # Monitoring engines
│   │   │   ├── mod.rs
│   │   │   ├── http.rs           # HTTP health checks
│   │   │   ├── websocket.rs      # WebSocket monitoring
│   │   │   ├── balance.rs        # Blockchain balance checks
│   │   │   └── graphql.rs        # GraphQL monitoring
│   │   ├── canary/                # Canary flow orchestrator
│   │   │   ├── mod.rs
│   │   │   ├── parser.rs         # Parse flow definitions
│   │   │   ├── executor.rs       # Execute multi-step flows
│   │   │   └── steps/
│   │   │       ├── http.rs
│   │   │       ├── blockchain.rs
│   │   │       └── custom.rs
│   │   ├── alerts/                # Alert delivery
│   │   │   ├── mod.rs
│   │   │   ├── discord.rs
│   │   │   ├── telegram.rs
│   │   │   ├── email.rs
│   │   │   └── sms.rs
│   │   ├── payments/              # USDC payment verification
│   │   │   ├── mod.rs
│   │   │   ├── usdc.rs           # EIP-3009 verification
│   │   │   └── x402.rs           # x402 protocol
│   │   ├── blockchain/            # Blockchain RPC clients
│   │   │   ├── mod.rs
│   │   │   ├── avalanche.rs
│   │   │   ├── base.rs
│   │   │   └── polygon.rs
│   │   ├── db/                    # Database layer
│   │   │   ├── mod.rs
│   │   │   ├── subscriptions.rs
│   │   │   ├── checks.rs
│   │   │   └── alerts.rs
│   │   └── i18n/                  # Internationalization
│   │       ├── mod.rs
│   │       └── loader.rs
│   └── tests/
│       ├── integration/
│       └── unit/
│
├── workers/                        # Python workers (Celery)
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── main.py                    # Celery app
│   ├── canary_worker.py           # Canary flow execution
│   ├── browser.py                 # Playwright automation
│   └── screenshot.py              # Screenshot capture
│
├── frontend/                       # React dashboard (Phase 2)
│   ├── package.json
│   ├── Dockerfile
│   ├── src/
│   │   ├── App.tsx
│   │   ├── pages/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Pricing.tsx
│   │   │   └── Status.tsx
│   │   ├── components/
│   │   │   ├── SubscriptionCard.tsx
│   │   │   ├── MetricsChart.tsx
│   │   │   └── AlertHistory.tsx
│   │   └── i18n/
│   │       ├── en.json
│   │       └── es.json
│   └── public/
│
├── contracts/                      # Smart contracts (optional)
│   ├── src/
│   │   └── LighthouseRegistry.sol # ERC-8004 style registry
│   └── foundry.toml
│
├── terraform/                      # Infrastructure as code
│   ├── aws/                       # AWS ECS Fargate
│   │   ├── main.tf
│   │   ├── ecs.tf
│   │   └── variables.tf
│   ├── eigencloud/                # EigenCloud (research)
│   │   └── main.tf
│   └── akash/                     # Akash Network (future)
│       └── deploy.yml
│
├── docs/                          # Documentation
│   ├── API.md                     # API reference
│   ├── API.es.md
│   ├── PRICING.md                 # Pricing guide
│   ├── PRICING.es.md
│   ├── CANARY_GUIDE.md            # Canary flow tutorial
│   ├── CANARY_GUIDE.es.md
│   ├── DEPLOYMENT.md              # Deployment guide
│   ├── DEPLOYMENT.es.md
│   └── guides/
│       ├── quickstart.md
│       ├── quickstart.es.md
│       ├── multi-chain.md
│       └── self-hosting.md
│
├── scripts/                       # Utility scripts
│   ├── deploy.sh                  # Production deployment
│   ├── fund-wallets.py            # Fund test wallets
│   ├── sync-translations.sh       # Check .md ↔ .es.md sync
│   └── benchmark.py               # Performance testing
│
├── tests/                         # Integration tests
│   ├── test_http_monitor.py
│   ├── test_canary_flows.py
│   ├── test_usdc_payments.py
│   └── test_multi_chain.py
│
├── i18n/                          # Translation files
│   ├── en.json                    # English strings
│   └── es.json                    # Spanish strings
│
└── .github/
    └── workflows/
        ├── ci.yml                 # Continuous integration
        ├── deploy-staging.yml
        └── deploy-production.yml
```

### Database Schema (TimescaleDB/PostgreSQL)

**Tables:**

**1. subscriptions** (relational)
```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_address TEXT NOT NULL,
  target_type TEXT NOT NULL,         -- 'http', 'canary', 'balance', 'contract'
  target_config JSONB NOT NULL,      -- Flexible JSON for different monitor types
  tier TEXT NOT NULL,                -- 'free', 'basic', 'standard', 'pro', 'enterprise'
  check_frequency_seconds INT NOT NULL,
  alert_channels JSONB,              -- Array of alert channel configs
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  active BOOLEAN DEFAULT TRUE,
  payment_tx TEXT,                   -- 0xDEF... (on-chain tx hash)
  payment_chain TEXT,                -- 'avalanche_fuji', 'base_sepolia', etc
  last_check_at TIMESTAMPTZ,
  next_check_at TIMESTAMPTZ,
  consecutive_failures INT DEFAULT 0,
  total_alerts_sent INT DEFAULT 0
);

CREATE INDEX idx_subscriptions_active ON subscriptions(active, next_check_at);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_address);
```

**2. check_history** (TimescaleDB hypertable)
```sql
CREATE TABLE check_history (
  time TIMESTAMPTZ NOT NULL,         -- Time-series primary dimension
  subscription_id UUID NOT NULL REFERENCES subscriptions(id),
  status TEXT NOT NULL,              -- 'success', 'failed', 'timeout', 'error'
  http_status INT,
  response_time_ms INT,
  timings JSONB,                     -- {dns_lookup_ms, tcp_connect_ms, ...}
  error_message TEXT,
  response_body TEXT,                -- Truncated to 1KB
  state_change BOOLEAN DEFAULT FALSE,
  alert_triggered BOOLEAN DEFAULT FALSE
);

-- Convert to hypertable (TimescaleDB magic!)
SELECT create_hypertable('check_history', 'time');

-- Add compression (10x storage savings)
ALTER TABLE check_history SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'subscription_id'
);

-- Enable automatic compression for chunks older than 7 days
SELECT add_compression_policy('check_history', INTERVAL '7 days');

-- Auto-delete data older than 90 days
SELECT add_retention_policy('check_history', INTERVAL '90 days');
```

**3. hourly_metrics** (Continuous aggregate - auto-computed)
```sql
CREATE MATERIALIZED VIEW hourly_metrics
WITH (timescaledb.continuous) AS
SELECT
  subscription_id,
  time_bucket('1 hour', time) AS hour,
  COUNT(*) as total_checks,
  COUNT(*) FILTER (WHERE status = 'success') as successful_checks,
  COUNT(*) FILTER (WHERE status != 'success') as failed_checks,
  AVG(response_time_ms) as avg_latency_ms,
  MAX(response_time_ms) as max_latency_ms,
  MIN(response_time_ms) as min_latency_ms,
  (COUNT(*) FILTER (WHERE status = 'success') * 100.0 / COUNT(*)) as uptime_pct
FROM check_history
GROUP BY subscription_id, hour;

-- Refresh policy (update every hour)
SELECT add_continuous_aggregate_policy('hourly_metrics',
  start_offset => INTERVAL '3 hours',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour');
```

**4. canary_results** (JSONB for flexibility)
```sql
CREATE TABLE canary_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES subscriptions(id),
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  flow_name TEXT NOT NULL,
  total_duration_ms INT,
  status TEXT NOT NULL,              -- 'success', 'failed'
  steps JSONB,                       -- Array of step results
  screenshot_url TEXT,               -- S3 URL if failure
  failed_step INT
);

CREATE INDEX idx_canary_subscription ON canary_results(subscription_id, timestamp DESC);
```

**5. alerts**
```sql
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES subscriptions(id),
  check_time TIMESTAMPTZ,            -- Reference to check_history.time
  alert_type TEXT NOT NULL,          -- 'downtime', 'recovery', 'high_latency', 'low_balance'
  severity TEXT NOT NULL,            -- 'info', 'warning', 'critical'
  message TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  channels_sent TEXT[],              -- ARRAY['discord', 'telegram']
  delivery_status JSONB,
  retry_count INT DEFAULT 0,
  language TEXT DEFAULT 'en'
);

CREATE INDEX idx_alerts_subscription ON alerts(subscription_id, timestamp DESC);
```

**6. users** (optional, Phase 2)
```sql
CREATE TABLE users (
  wallet_address TEXT PRIMARY KEY,
  email TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  subscription_count INT DEFAULT 0,
  total_spent_usdc NUMERIC(18, 6),
  language_preference TEXT DEFAULT 'en'
);
```

**See complete implementation:** `lighthouse/TIMESCALEDB-IMPLEMENTATION-GUIDE.md`
```

### API Endpoints

**Public Endpoints:**
```
GET  /                    # Landing page info
GET  /health              # Lighthouse health status
GET  /pricing             # Pricing tiers and features
GET  /supported-chains    # List of supported blockchains
```

**Subscription Management (USDC payment required):**
```
POST   /subscribe                        # Create subscription
       Body: {
         target_type: "http" | "canary" | "balance",
         target_config: {...},
         tier: "basic" | "standard" | "pro" | "enterprise",
         alert_channels: [...]
       }
       Headers: X-Payment: base64(signed_usdc_authorization)

GET    /subscriptions/:id                # Get subscription details
       Auth: Signature proving wallet ownership

PUT    /subscriptions/:id                # Update subscription
       Auth: Signature proving wallet ownership

DELETE /subscriptions/:id                # Cancel subscription
       Auth: Signature proving wallet ownership

GET    /subscriptions/wallet/:address    # List all subscriptions for wallet
       Auth: Signature proving wallet ownership
```

**Metrics & Data:**
```
GET  /metrics/:subscription_id           # Get uptime metrics
     Query: ?period=7d|30d|90d|365d
     Auth: Signature proving ownership

GET  /checks/:subscription_id            # Get check history
     Query: ?limit=100&offset=0
     Auth: Signature proving ownership

GET  /alerts/:subscription_id            # Get alert history
     Auth: Signature proving ownership
```

**Canary Flows:**
```
POST /canaries                           # Create canary flow
     Body: { flow_definition: {...}, tier: "standard"+ }
     Headers: X-Payment: ...

GET  /canaries/:id/results               # Get canary results
     Auth: Signature proving ownership

GET  /canaries/:id/screenshot/:step      # Get failure screenshot
     Auth: Signature proving ownership
```

**Pay-Per-Use:**
```
POST /check/once                         # One-time check
     Body: { url: "...", method: "GET", ... }
     Headers: X-Payment: base64(0.001_usdc_authorization)
     Returns: Immediate check result
```

---

## ❓ Open Questions

### Technical Decisions

**1. Rust vs Python for Backend?**
- **Current decision:** Rust core + Python workers (hybrid)
- **Question:** Is hybrid complexity worth it, or go full Rust?
- **Research needed:** Benchmark Rust canary execution vs Python Playwright
- **Impact:** Development speed vs performance

**2. Playwright Mandatory?**
- **Context:** Playwright is 300MB+ dependency
- **Alternative:** Simple HTTP checks for 95% of use cases, Playwright optional
- **Question:** Ship Playwright by default or only for Pro tier?
- **Impact:** Docker image size, deployment complexity

**3. Self-Hosted Smart Contract?**
- **Context:** Could deploy ERC-8004 style registry for Lighthouse users
- **Benefit:** On-chain reputation, discoverability
- **Question:** Is blockchain needed for monitoring service?
- **Impact:** Development time, gas costs for users

**4. Multi-Region Deployment?**
- **Context:** Monitoring from single region (AWS us-east-1 or EigenCloud)
- **Question:** Should we monitor from multiple regions (like AWS Synthetics)?
- **Benefit:** Detect regional outages
- **Cost:** 3x infrastructure costs
- **Decision:** Defer to Phase 5+ (after product-market fit)

### Business Model

**5. Freemium vs Paid-Only?**
- **Current decision:** Free tier (1 endpoint, 1-hour checks)
- **Question:** Does free tier cannibalize paid users?
- **Alternative:** 14-day trial, then paid-only
- **Research:** Look at UptimeRobot (free tier), Pingdom (trial only)

**6. Annual Pricing Discount?**
- **Context:** Most SaaS offers 20% off for annual plans
- **Question:** Offer annual plans (10 USDC/year vs 12 USDC monthly)?
- **Benefit:** Predictable revenue, lower churn
- **Challenge:** USDC payment upfront, no refunds (on-chain)

**7. White-Label Pricing?**
- **Context:** Enterprise tier includes white-label option
- **Question:** What to charge? (Competitors: $500-2000/month)
- **Proposal:** $100/month (cheap to win customers)

### Ecosystem Fit

**8. Integrate with Karmacadabra?**
- **Question:** Should Lighthouse use ERC-8004 registry?
- **Pro:** Interoperability with Karmacadabra agents
- **Con:** Couples Lighthouse to Karmacadabra (violates standalone principle)
- **Decision:** Optional integration (Lighthouse can publish agent card, but not required)

**9. Accept GLUE as Payment?**
- **Question:** Support both USDC and GLUE?
- **Pro:** Karmacadabra users prefer GLUE
- **Con:** Complexity (two token contracts), GLUE is volatile
- **Decision:** Phase 2+ (after USDC works, add GLUE as secondary option)

**10. DAO Governance?**
- **Question:** Should Lighthouse be governed by UltravioletaDAO?
- **Pro:** Community-driven, decentralized decision-making
- **Con:** Slower decisions, harder to pivot
- **Proposal:** DAO owns treasury, operational decisions by core team

### Technical Risks

**11. EigenCloud Viability?**
- **Risk:** EigenCloud might be too new/unstable for production
- **Mitigation:** Deploy on AWS first, evaluate EigenCloud in parallel
- **Decision point:** Week 6 (benchmark results)

**12. ChaosChain Integration?**
- **Risk:** ChaosChain is experimental ("arbitrary state transitions")
- **Question:** Is chaos testing a must-have or nice-to-have?
- **Decision:** Nice-to-have, defer to Phase 4+

**13. USDC Polygon Bridged Variant?**
- **Risk:** Polygon bridged USDC has different EIP-712 signature format
- **Question:** Support Polygon or skip initially?
- **Decision:** Support Avalanche + Base first, add Polygon in Phase 2

### Go-to-Market

**14. How to Onboard First 100 Users?**
- **Strategy 1:** Manual outreach (DM top DeFi protocols)
- **Strategy 2:** Community (post to Reddit, Discord, Twitter)
- **Strategy 3:** Partnerships (Alchemy, The Graph, Chainlink)
- **Question:** Which channel converts best?
- **Experiment:** Try all three in Month 1, double down on winner

**15. Pricing: Too Cheap?**
- **Context:** $1/month for 10 endpoints is 10x cheaper than competitors
- **Question:** Are we leaving money on the table?
- **Alternative:** Start at $5/month, lower price if adoption is slow
- **Decision:** Start cheap ($1/month), raise prices once proven (grandfather early users)

---

## 🎬 Conclusion

### Summary

**Lighthouse (Faro)** is a **universal, trustless monitoring platform** designed for Web3:

✅ **50x cheaper than AWS Synthetics** ($1/month vs $51/month for 5-min checks)
✅ **Crypto-native** (USDC payments, blockchain monitoring built-in)
✅ **Multi-cloud** (EigenCloud OR AWS, not locked to one provider)
✅ **Open-source** (audit code, contribute features, self-host)
✅ **Bilingual** (English + Spanish from day 1)
✅ **Canary flows** (AWS Synthetics equivalent, multi-step scenarios)
✅ **Balance monitoring** (native tokens: AVAX, ETH, MATIC)

### Why This Will Succeed

**1. Clear Market Gap:**
- Existing monitoring services are expensive ($5-52/month)
- None are crypto-native (all require credit cards)
- None offer blockchain-specific monitoring (smart contracts, balances)

**2. 10-100x Larger Market than WatchTower:**
- WatchTower: 53 agents (Karmacadabra-only) = $2-3/month revenue
- Lighthouse: 1000+ Web3 projects = $200-1000/month revenue
- **30-300x revenue potential**

**3. Proven Demand:**
- AWS Synthetics: $10.71+ per canary = people ARE paying for monitoring
- UptimeRobot: 1M+ users = monitoring is essential, not optional
- Crypto projects: High uptime requirements (DeFi, NFTs, DAOs)

**4. Sustainable Business Model:**
- Break-even: 57 subscribers (EigenCloud) or 77 subscribers (AWS)
- Achievable in Q1-Q2 (Karmacadabra + Web3 communities)
- Path to $25k+/year revenue in Year 1

**5. Technical Moat:**
- Rust + TimescaleDB = 10x more efficient than competitors' stacks
- Multi-cloud = no vendor lock-in
- Open-source = community contributions accelerate development

### What Makes This Different from WatchTower?

| Aspect | WatchTower | Lighthouse |
|--------|------------|------------|
| **Vision** | Internal tool for Karmacadabra | Universal product for Web3 ecosystem |
| **Payment** | GLUE (ecosystem token) | USDC (universal stablecoin) |
| **Market** | 53 agents | 1000+ Web3 projects |
| **Revenue** | $2-3/month | $200-1000/month (100x potential) |
| **Features** | HTTP monitoring only | HTTP + Canary + Blockchain + WebSocket + GraphQL |
| **Deployment** | AWS ECS Fargate only | Multi-cloud (EigenCloud, AWS, Akash) |
| **Branding** | English-only | Bilingual (English + Spanish) |

**Decision:** **Lighthouse supersedes WatchTower entirely**. WatchTower design is archived, Lighthouse is the production system.

### Risks & Mitigations

**Risk 1: EigenCloud is not production-ready**
- **Mitigation:** Deploy on AWS first, evaluate EigenCloud in Week 6
- **Fallback:** Stay on AWS if EigenCloud doesn't work

**Risk 2: USDC adoption is slow (users prefer GLUE)**
- **Mitigation:** Add GLUE support in Phase 2
- **Data point:** USDC has $30B+ supply, GLUE has $0 (not launched yet)

**Risk 3: No users beyond Karmacadabra**
- **Mitigation:** Validate demand in Month 1-2 (post to r/ethereum, Web3 Discord)
- **Pivot:** If no external demand, narrow scope to Karmacadabra-only (revert to WatchTower)

**Risk 4: Canary flows too complex to implement**
- **Mitigation:** MVP focuses on HTTP monitoring (simpler)
- **Canary flows:** Phase 2 (can defer if MVP adoption is strong)

**Risk 5: AWS Synthetics lowers prices (competitive response)**
- **Mitigation:** We're 50x cheaper, they can't match without losing money
- **Advantage:** Crypto-native payments + blockchain monitoring (they can't copy easily)

### Next Steps

**Immediate (Week 1):**
1. ✅ Review this master plan with UltravioletaDAO community
2. ✅ Approve budget: $500 for Q1 (subsidized hosting + domain)
3. ✅ Create `karmacadabra/lighthouse/` directory structure
4. ✅ Start MVP development (Rust backend, HTTP monitoring)

**Short-Term (Week 2-4):**
1. Deploy MVP to AWS ECS Fargate
2. Onboard first 10 customers (Karmacadabra agents)
3. Collect feedback, iterate on pricing/features
4. Launch canary flows (Phase 2)

**Medium-Term (Month 2-3):**
1. Public launch (blog post, Twitter, Reddit)
2. Onboard 100 external customers (Web3 projects)
3. Evaluate EigenCloud (parallel deployment)
4. Decide: Migrate to EigenCloud or stay on AWS

**Long-Term (Month 4-12):**
1. Add blockchain monitoring (balances, contracts)
2. Multi-chain USDC support (Base, Polygon)
3. Enterprise features (white-label, chaos testing)
4. Path to profitability (200+ subscribers)

### Success Metrics

**Month 1-2 (MVP):**
- [ ] 15 subscribers (Karmacadabra agents)
- [ ] 500+ checks executed (prove system works)
- [ ] 0 false positives (reliability)

**Month 3-4 (Growth):**
- [ ] 100 subscribers (50% external, 50% Karmacadabra)
- [ ] $100/month revenue
- [ ] 5 testimonials (social proof)

**Month 5-6 (Scale):**
- [ ] 500 subscribers
- [ ] $600/month revenue (break-even)
- [ ] 10+ reviews (Reddit, Twitter, Product Hunt)

**Month 7-12 (Profitability):**
- [ ] 2000+ subscribers
- [ ] $2000/month revenue
- [ ] 1 partnership (Alchemy, The Graph, etc)
- [ ] 1 enterprise customer ($100+/month)

### Final Recommendation

**APPROVE LIGHTHOUSE DEVELOPMENT**

**Justification:**
1. **Market need:** Web3 projects need cheap, crypto-native monitoring (AWS is 50x too expensive)
2. **Revenue potential:** 100x larger market than WatchTower ($200-1000/month vs $2-3/month)
3. **Technical feasibility:** Rust + TimescaleDB + x402 = proven technologies
4. **Low risk:** $500 investment, 2-week MVP, clear validation milestones
5. **Strategic value:** Lighthouse strengthens Ultravioleta DAO ecosystem (not just Karmacadabra)

**Domain:** `lighthouse.ultravioletadao.xyz` + `faro.ultravioletadao.xyz`
**Budget:** $500 for Q1 (hosting + domain + marketing)
**Timeline:** 2 weeks to MVP, 6 weeks to public launch
**Break-even:** Month 5-6 (57-77 subscribers)
**Year 1 Target:** $2000/month revenue, 2000+ users

---

**Document Version:** 2.0.0
**Author:** Master Architect (Claude Code)
**Date:** October 28, 2025
**Status:** Ready for Review & Approval
**Supersedes:** WatchTower design (October 28, 2025)

**Next Action:** Present to UltravioletaDAO community for approval, begin MVP development Week 1.
