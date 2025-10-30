# Lighthouse Architecture Diagrams

**Date:** October 28, 2025

---

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Lighthouse Platform                          │
│                    (Universal Web3 Monitoring)                       │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
            ┌───────▼────────┐       ┌───────▼────────┐
            │  Rust Backend  │       │ Python Workers │
            │  (Axum + Tokio)│       │   (Celery)     │
            │                │       │                │
            │ • HTTP API     │       │ • Playwright   │
            │ • Scheduler    │       │ • Screenshots  │
            │ • Monitors     │       │ • Complex      │
            │ • Payments     │       │   Scenarios    │
            └───────┬────────┘       └───────┬────────┘
                    │                        │
        ┌───────────┼────────────┬───────────┼───────────┐
        │           │            │           │           │
   ┌────▼────┐ ┌───▼───┐  ┌────▼────┐ ┌────▼────┐ ┌───▼────┐
   │  HTTP   │ │Balance│  │WebSocket│ │ Canary  │ │Browser │
   │ Monitor │ │Monitor│  │ Monitor │ │Executor │ │ Auto   │
   └────┬────┘ └───┬───┘  └────┬────┘ └────┬────┘ └───┬────┘
        │          │           │            │          │
        └──────────┴───────────┴────────────┴──────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            ┌───────▼────────┐     ┌───────▼────────┐
            │   MongoDB      │     │     Redis      │
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

---

## 2. HTTP Monitoring Flow (Basic Check)

```
┌──────────┐                                    ┌─────────────┐
│  User    │                                    │  Lighthouse │
│ (Buyer)  │                                    │   Backend   │
└────┬─────┘                                    └──────┬──────┘
     │                                                  │
     │ 1. Sign USDC payment (1.00 USDC for Standard)  │
     │─────────────────────────────────────────────────>│
     │   POST /subscribe                                │
     │   X-Payment: base64(signed_authorization)        │
     │   Body: {                                        │
     │     target_type: "http",                         │
     │     target_config: {                             │
     │       url: "https://api.example.com/health",     │
     │       valid_status_codes: [200, 201],            │
     │       max_latency_ms: 5000                       │
     │     },                                           │
     │     tier: "standard",                            │
     │     alert_channels: [...]                        │
     │   }                                              │
     │                                                  │
     │                                       2. Verify USDC payment
     │                                          (EIP-3009 signature)
     │                                                  │
     │                                       3. Execute on-chain
     │                                          (transferWithAuthorization)
     │                                                  │
     │ 4. Subscription created                         │
     │<─────────────────────────────────────────────────│
     │   {                                              │
     │     subscription_id: "sub_123",                  │
     │     status: "active",                            │
     │     check_frequency: 300,  // 5 min              │
     │     next_check_at: "2025-10-28T10:05:00Z"        │
     │   }                                              │
     │                                                  │
     │                                       5. Background scheduler
     │                                          starts monitoring
     │                                                  │
     └──────────────────────────────────────────────────┘

┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│ Lighthouse  │         │   Target     │         │   MongoDB    │
│  Scheduler  │         │   Service    │         │   Database   │
└──────┬──────┘         └──────┬───────┘         └──────┬───────┘
       │                       │                        │
       │ 6. Check timer        │                        │
       │    (every 5 min)      │                        │
       │                       │                        │
       │ 7. GET /health        │                        │
       │──────────────────────>│                        │
       │                       │                        │
       │ 8. Response           │                        │
       │   (200 OK, 145ms)     │                        │
       │<──────────────────────│                        │
       │                       │                        │
       │ 9. Store result       │                        │
       │────────────────────────────────────────────────>│
       │   {                   │                        │
       │     status: "success",│                        │
       │     http_status: 200, │                        │
       │     latency_ms: 145,  │                        │
       │     timestamp: ...    │                        │
       │   }                   │                        │
       │                       │                        │
       │ 10. Check thresholds  │                        │
       │     (200 in [200,201]?)│                       │
       │     (145ms < 5000ms?) │                        │
       │                       │                        │
       │ 11. No alert needed   │                        │
       │     (all checks pass) │                        │
       └───────────────────────────────────────────────┘
```

---

## 3. Canary Flow (Multi-Step Scenario)

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────┐
│ Lighthouse  │    │   Step 1     │    │   Step 2    │    │  Step 3  │
│   Canary    │    │  (Homepage)  │    │ (Add Cart)  │    │(Checkout)│
│  Executor   │    │              │    │             │    │          │
└──────┬──────┘    └──────┬───────┘    └──────┬──────┘    └─────┬────┘
       │                  │                    │                  │
       │ 1. Start flow    │                    │                  │
       │   "E-commerce    │                    │                  │
       │    Checkout"     │                    │                  │
       │                  │                    │                  │
       │ 2. Execute Step 1│                    │                  │
       │──────────────────>│                    │                  │
       │   GET /          │                    │                  │
       │                  │                    │                  │
       │ 3. Response      │                    │                  │
       │   200 OK         │                    │                  │
       │<──────────────────│                    │                  │
       │                  │                    │                  │
       │ 4. Validate:     │                    │                  │
       │   ✓ Status 200   │                    │                  │
       │   ✓ Contains     │                    │                  │
       │     "Add to Cart"│                    │                  │
       │                  │                    │                  │
       │ 5. Execute Step 2│                    │                  │
       │─────────────────────────────────────────>│                  │
       │   POST /api/cart │                    │                  │
       │   Body: {product_id: 123}             │                  │
       │                  │                    │                  │
       │ 6. Response      │                    │                  │
       │   201 Created    │                    │                  │
       │<─────────────────────────────────────────│                  │
       │                  │                    │                  │
       │ 7. Extract var:  │                    │                  │
       │   CART_ID = "abc123"                  │                  │
       │                  │                    │                  │
       │ 8. Execute Step 3│                    │                  │
       │────────────────────────────────────────────────────────────>│
       │   POST /api/checkout                  │                  │
       │   Body: {cart_id: "${CART_ID}"}       │                  │
       │                  │                    │                  │
       │ 9. Response      │                    │                  │
       │   200 OK         │                    │                  │
       │<────────────────────────────────────────────────────────────│
       │   {order_id: "xyz789"}                │                  │
       │                  │                    │                  │
       │ 10. Flow SUCCESS │                    │                  │
       │     Total: 892ms │                    │                  │
       │     Step 1: 234ms│                    │                  │
       │     Step 2: 345ms│                    │                  │
       │     Step 3: 313ms│                    │                  │
       │                  │                    │                  │
       └──────────────────────────────────────────────────────────┘

       ┌───────────────────────────────────────────────────────────┐
       │ If Step 2 fails (e.g., 503 error):                       │
       │                                                           │
       │ 1. Canary executor detects failure                       │
       │ 2. Triggers Python worker (Playwright)                   │
       │ 3. Playwright captures screenshot of page                │
       │ 4. Screenshot uploaded to S3                             │
       │ 5. Alert sent to Discord:                                │
       │    "🔴 Canary Flow Failed: E-commerce Checkout"          │
       │    "Failed at Step 2: Add to Cart"                       │
       │    "Error: HTTP 503 Service Unavailable"                 │
       │    "Screenshot: https://s3.../screenshot.png"            │
       └───────────────────────────────────────────────────────────┘
```

---

## 4. Blockchain Balance Monitoring

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│ Lighthouse  │         │  Avalanche   │         │   Discord    │
│  Balance    │         │   RPC Node   │         │   Webhook    │
│  Monitor    │         │              │         │              │
└──────┬──────┘         └──────┬───────┘         └──────┬───────┘
       │                       │                        │
       │ 1. Schedule check     │                        │
       │    (every 5 min)      │                        │
       │                       │                        │
       │ 2. Query balance      │                        │
       │────────────────────────>│                        │
       │   eth_getBalance(     │                        │
       │     "0xABC...",       │                        │
       │     "latest"          │                        │
       │   )                   │                        │
       │                       │                        │
       │ 3. Response           │                        │
       │   "0x16345785D8A0000"│                        │
       │   (0.1 AVAX)          │                        │
       │<────────────────────────│                        │
       │                       │                        │
       │ 4. Convert to decimal │                        │
       │    0x16345785D8A0000 │                        │
       │    = 100000000000000000│                        │
       │    = 0.1 AVAX         │                        │
       │                       │                        │
       │ 5. Check threshold    │                        │
       │    Balance: 0.1 AVAX  │                        │
       │    Alert: < 0.1 AVAX  │                        │
       │    Critical: < 0.01   │                        │
       │                       │                        │
       │ 6. ⚠️ TRIGGER ALERT   │                        │
       │    (balance at        │                        │
       │     threshold)        │                        │
       │                       │                        │
       │ 7. Send alert         │                        │
       │────────────────────────────────────────────────>│
       │   POST webhook        │                        │
       │   {                   │                        │
       │     "content": "⚠️ Low Balance Alert",         │
       │     "embeds": [{      │                        │
       │       "title": "Avalanche Facilitator",        │
       │       "description": "Balance: 0.1 AVAX",      │
       │       "color": 16776960,  // Yellow            │
       │       "fields": [     │                        │
       │         {             │                        │
       │           "name": "Address",                   │
       │           "value": "0xABC..."                  │
       │         },            │                        │
       │         {             │                        │
       │           "name": "Alert Threshold",           │
       │           "value": "0.1 AVAX"                  │
       │         },            │                        │
       │         {             │                        │
       │           "name": "Critical Threshold",        │
       │           "value": "0.01 AVAX"                 │
       │         }             │                        │
       │       ]               │                        │
       │     }]                │                        │
       │   }                   │                        │
       │                       │                        │
       │ 8. Alert delivered    │                        │
       │<────────────────────────────────────────────────│
       │   200 OK              │                        │
       │                       │                        │
       └───────────────────────────────────────────────┘

       ┌───────────────────────────────────────────────────────────┐
       │ If balance drops below CRITICAL (0.01 AVAX):              │
       │                                                           │
       │ 1. Change alert color to RED                             │
       │ 2. Change severity to CRITICAL                           │
       │ 3. Send to ALL configured channels (Discord + Telegram + │
       │    Email + SMS for Enterprise tier)                      │
       │ 4. Repeat alert every 5 minutes until balance restored   │
       └───────────────────────────────────────────────────────────┘
```

---

## 5. Multi-Cloud Deployment Architecture

```
                            ┌─────────────────┐
                            │   Cloudflare    │
                            │  (DNS + DDoS)   │
                            └────────┬────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
        ┌───────────▼───────────┐       ┌────────────▼────────────┐
        │ lighthouse.ultravioleta│       │ faro.ultravioletadao.xyz│
        │     dao.xyz (EN)       │       │         (ES)            │
        └───────────┬───────────┘       └────────────┬────────────┘
                    │                                 │
                    └────────────────┬────────────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
            ┌───────▼────────┐              ┌────────▼────────┐
            │  EigenCloud    │              │   AWS Fargate   │
            │  (Primary)     │              │   (Fallback)    │
            │                │              │                 │
            │ • Verifiable   │              │ • Known tech    │
            │   monitoring   │              │ • High uptime   │
            │ • On-chain     │              │ • Easy scaling  │
            │   proofs       │              │                 │
            │ • $15/month    │              │ • $30/month     │
            └───────┬────────┘              └────────┬────────┘
                    │                                 │
                    │ HTTP health checks              │
                    │ run from BOTH                   │
                    │ locations                       │
                    │                                 │
                    └────────────────┬────────────────┘
                                     │
                    ┌────────────────▼────────────────┐
                    │     MongoDB Atlas (Shared)      │
                    │                                 │
                    │ • Time-series collections       │
                    │ • Automatic backups             │
                    │ • Multi-region replication      │
                    └─────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────┐
│ Future: Akash Network (Decentralized Cloud)                           │
│                                                                       │
│ • Deploy Lighthouse on Akash (community-hosted)                      │
│ • $5-10/month (50% cheaper than AWS)                                 │
│ • True decentralization (no single cloud provider)                   │
│ • Users can run their own Lighthouse instance (self-hosted)          │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 6. USDC Payment Flow (Multi-Chain)

```
┌──────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────┐
│  User    │     │  Lighthouse  │     │  Blockchain │     │   USDC   │
│ (Wallet) │     │   Backend    │     │  RPC Node   │     │ Contract │
└────┬─────┘     └──────┬───────┘     └──────┬──────┘     └─────┬────┘
     │                  │                     │                   │
     │ 1. User selects  │                     │                   │
     │    chain         │                     │                   │
     │    (Avalanche,   │                     │                   │
     │     Base, or     │                     │                   │
     │     Polygon)     │                     │                   │
     │                  │                     │                   │
     │ 2. Sign EIP-3009 │                     │                   │
     │    authorization │                     │                   │
     │    (off-chain)   │                     │                   │
     │                  │                     │                   │
     │  Domain: {       │                     │                   │
     │    name: "USD Coin",                   │                   │
     │    version: "2", │                     │                   │
     │    chainId: ..., │                     │                   │
     │    verifyingContract: USDC_ADDRESS     │                   │
     │  }               │                     │                   │
     │                  │                     │                   │
     │  Message: {      │                     │                   │
     │    from: user,   │                     │                   │
     │    to: lighthouse,│                    │                   │
     │    value: 1000000,  // 1.00 USDC (6 decimals)             │
     │    validAfter: 0,│                     │                   │
     │    validBefore: now+1h,                │                   │
     │    nonce: random │                     │                   │
     │  }               │                     │                   │
     │                  │                     │                   │
     │ 3. Send signed   │                     │                   │
     │    authorization │                     │                   │
     │──────────────────>│                     │                   │
     │  POST /subscribe │                     │                   │
     │  X-Payment: base64(v, r, s, ...)       │                   │
     │                  │                     │                   │
     │                  │ 4. Verify signature │                   │
     │                  │    (off-chain)      │                   │
     │                  │    - Recover signer │                   │
     │                  │    - Check amount   │                   │
     │                  │    - Check validity │                   │
     │                  │                     │                   │
     │                  │ 5. Execute on-chain │                   │
     │                  │────────────────────>│                   │
     │                  │ transferWithAuth    │                   │
     │                  │ (from, to, value,   │                   │
     │                  │  validAfter, ...)   │                   │
     │                  │                     │                   │
     │                  │                     │ 6. Call contract  │
     │                  │                     │───────────────────>│
     │                  │                     │ USDC.transferWith │
     │                  │                     │ Authorization(...) │
     │                  │                     │                   │
     │                  │                     │ 7. Verify signature│
     │                  │                     │    (on-chain)     │
     │                  │                     │                   │
     │                  │                     │ 8. Transfer tokens│
     │                  │                     │    from → to      │
     │                  │                     │                   │
     │                  │                     │ 9. Emit event     │
     │                  │                     │<───────────────────│
     │                  │                     │ Transfer(from,    │
     │                  │                     │   to, 1000000)    │
     │                  │                     │                   │
     │                  │ 10. Transaction     │                   │
     │                  │     confirmed       │                   │
     │                  │<────────────────────│                   │
     │                  │ tx_hash: 0xDEF...   │                   │
     │                  │                     │                   │
     │ 11. Subscription │                     │                   │
     │     activated    │                     │                   │
     │<──────────────────│                     │                   │
     │  {               │                     │                   │
     │    subscription_id: "sub_123",         │                   │
     │    status: "active",                   │                   │
     │    payment_tx: "0xDEF...",             │                   │
     │    payment_chain: "avalanche_fuji"     │                   │
     │  }               │                     │                   │
     │                  │                     │                   │
     └──────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────┐
│ Multi-Chain Support:                                                  │
│                                                                       │
│ • Avalanche Fuji: USDC at 0x5425890298aed601595a70AB815c96711a31Bc65│
│ • Base Sepolia: USDC at 0x036CbD53842c5426634e7929541eC2318f3dCF7e  │
│ • Polygon Mumbai: USDC at 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97│
│                                                                       │
│ User chooses chain in UI, Lighthouse automatically uses correct       │
│ contract address and chain ID for signature verification.            │
└───────────────────────────────────────────────────────────────────────┘
```

---

## 7. Comparison: WatchTower vs Lighthouse

```
┌─────────────────────────────────────────────────────────────────────┐
│                          WatchTower (OLD)                            │
│                    (Karmacadabra Agents Only)                        │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
            ┌───────▼────────┐       ┌───────▼────────┐
            │  Python Agent  │       │   MongoDB      │
            │  (FastAPI)     │       │                │
            │                │       │ • Subscriptions│
            │ • HTTP checks  │       │ • Check history│
            │ • Discord only │       │ • 7-day retain │
            └───────┬────────┘       └────────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
   ┌────▼────┐ ┌───▼───┐ ┌────▼────┐
   │ 53 agents│ │ GLUE  │ │$0.02/mo│
   │ (max)   │ │payment│ │ revenue │
   └─────────┘ └───────┘ └─────────┘

Limitations:
❌ Karmacadabra-only (53 agents max)
❌ HTTP monitoring only (no canary flows)
❌ Fixed status codes (200 = success)
❌ GLUE payment (volatile, low liquidity)
❌ Never profitable (operating costs > revenue)

─────────────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────────────┐
│                         Lighthouse (NEW)                             │
│                  (Universal Web3 Monitoring)                         │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
            ┌───────▼────────┐       ┌───────▼────────┐
            │  Rust Backend  │       │ Python Workers │
            │  (Axum + Tokio)│       │   (Celery)     │
            │                │       │                │
            │ • HTTP API     │       │ • Playwright   │
            │ • Scheduler    │       │ • Screenshots  │
            │ • Multi-monitor│       │ • Canary flows │
            └───────┬────────┘       └───────┬────────┘
                    │                        │
        ┌───────────┼────────────┬───────────┼───────────┐
        │           │            │           │           │
   ┌────▼────┐ ┌───▼───┐  ┌────▼────┐ ┌────▼────┐ ┌───▼────┐
   │  HTTP   │ │Balance│  │WebSocket│ │ Canary  │ │Browser │
   │ Monitor │ │Monitor│  │ Monitor │ │ Flows   │ │ Auto   │
   └────┬────┘ └───┬───┘  └────┬────┘ └────┬────┘ └───┬────┘
        │          │           │            │          │
        └──────────┴───────────┴────────────┴──────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            ┌───────▼────────┐     ┌───────▼────────┐
            │   MongoDB      │     │     Redis      │
            │ (Time-Series)  │     │   (Cache)      │
            └───────┬────────┘     └────────────────┘
                    │
        ┌───────────┼───────────┬───────────┐
        │           │           │           │
   ┌────▼────┐ ┌───▼───┐ ┌────▼────┐ ┌────▼────┐
   │1000+    │ │ USDC  │ │$1000+/mo│ │Multi-   │
   │projects │ │payment│ │ revenue │ │channel  │
   └─────────┘ └───────┘ └─────────┘ └─────────┘

Advantages:
✅ Universal (any Web3 project, 1000+ market)
✅ 5 monitoring types (HTTP, Canary, Balance, WebSocket, GraphQL)
✅ Configurable status codes ([200, 201, 202, ...])
✅ USDC payment (stable, liquid, universal)
✅ Profitable in 6 months (57-77 subscribers)
✅ Multi-cloud (EigenCloud, AWS, Akash)
✅ Bilingual (English + Spanish)
✅ 50x cheaper than AWS Synthetics
```

---

**Document Version:** 1.0.0
**Author:** Master Architect (Claude Code)
**Date:** October 28, 2025
**Related:** See `lighthouse-master-plan.md` for full specifications
