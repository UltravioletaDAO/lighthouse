# 🔦 Lighthouse / Faro - Universal Trustless Monitoring Platform

**Status:** Design Phase
**Version:** 2.0.0
**Location:** `z:\ultravioleta\dao\karmacadabra\lighthouse\`
**Domains:** `lighthouse.ultravioletadao.xyz` (EN) | `faro.ultravioletadao.xyz` (ES)

---

## 🎯 What is Lighthouse?

Lighthouse is a **universal, trustless monitoring platform** for the Web3 ecosystem that provides:

- ✅ **HTTP/API Monitoring** (configurable status codes: 200, 201, 202, 301, 302, etc.)
- ✅ **Canary Flows** (AWS CloudWatch Synthetics equivalent - multi-step scenarios)
- ✅ **Blockchain Monitoring** (native token balances: AVAX, ETH, MATIC for facilitators)
- ✅ **WebSocket Monitoring** (real-time data streams)
- ✅ **GraphQL Monitoring** (query validation, schema checks)
- ✅ **Multi-Channel Alerts** (Discord, Telegram, Email, Slack, SMS)

**Key Innovation:** Pay with **USDC** (universal, stable, multi-chain) via x402 protocol.

**Competitive Advantage:** **50x cheaper than AWS Synthetics** ($0.20/month vs $51.84/month for 5-min checks)

---

## 📚 Documentation Navigation

### Core Documents

| Document | Description | Status |
|----------|-------------|--------|
| **[lighthouse-master-plan.md](./lighthouse-master-plan.md)** | Complete technical specifications (60+ pages) | ✅ Complete |
| **[lighthouse-vs-watchtower.md](./lighthouse-vs-watchtower.md)** | Why Lighthouse supersedes WatchTower | ✅ Complete |
| **[lighthouse-architecture-diagram.md](./lighthouse-architecture-diagram.md)** | ASCII diagrams for all major flows | ✅ Complete |
| **[lighthouse-quick-reference.md](./lighthouse-quick-reference.md)** | Quick summary for presentations | ✅ Complete |

### What to Read First

**If you have 5 minutes:**
→ Read [lighthouse-quick-reference.md](./lighthouse-quick-reference.md)

**If you have 30 minutes:**
→ Read [lighthouse-vs-watchtower.md](./lighthouse-vs-watchtower.md)
→ Skim [lighthouse-architecture-diagram.md](./lighthouse-architecture-diagram.md)

**If you have 2 hours:**
→ Read [lighthouse-master-plan.md](./lighthouse-master-plan.md) completely

**If you're a developer:**
→ Read "Technology Stack" and "Implementation Roadmap" sections in [lighthouse-master-plan.md](./lighthouse-master-plan.md)

**If you're business/community:**
→ Read "Business Model" and "Competitive Analysis" sections in [lighthouse-master-plan.md](./lighthouse-master-plan.md)

---

## 🏗️ Project Structure (Current)

This directory contains the complete Lighthouse project:

```
karmacadabra/lighthouse/            # z:\ultravioleta\dao\karmacadabra\lighthouse\
├── README.md                       # This file (navigation guide)
├── README.es.md                    # Spanish version (TBD)
├── ARCHITECTURE.md                 # System design details (TBD)
├── lighthouse-master-plan.md       # ✅ Complete technical specifications
├── lighthouse-vs-watchtower.md     # ✅ Comparison & justification
├── lighthouse-architecture-diagram.md  # ✅ ASCII diagrams
├── lighthouse-quick-reference.md   # ✅ Quick summary
│
├── backend/                        # Rust core (TBD)
│   ├── Cargo.toml
│   ├── src/
│   │   ├── main.rs
│   │   ├── monitors/
│   │   ├── canary/
│   │   └── alerts/
│
├── workers/                        # Python workers for canary flows (TBD)
│   ├── requirements.txt
│   ├── playwright_worker.py
│
├── frontend/                       # Dashboard UI (Phase 2, TBD)
│   ├── src/
│   └── public/
│
├── terraform/                      # Infrastructure as Code (TBD)
│   ├── eigencloud/
│   └── aws/
│
├── docker-compose.yml              # Local development (TBD)
├── docker-compose.prod.yml         # Production deployment (TBD)
│
├── docs/                           # Additional documentation (TBD)
│   ├── API.md
│   ├── PRICING.md
│   └── CANARY_GUIDE.md
│
├── scripts/                        # Utility scripts (TBD)
│   ├── deploy.sh
│   └── fund-wallets.py
│
└── tests/                          # Test suite (TBD)
    ├── test_http_monitor.rs
    └── test_canary_flows.py
```

---

## 💰 Pricing (USDC-based)

| Tier | Frequency | Endpoints | Price/Month | Equivalent Service | Savings |
|------|-----------|-----------|-------------|-------------------|---------|
| **Free** | 1 hour | 1 | $0 USDC | UptimeRobot Free | - |
| **Basic** | 15 min | 3 | $0.20 USDC | UptimeRobot Pro ($7) | **35x cheaper** |
| **Standard** | 5 min | 10 | $1.00 USDC | Pingdom ($15) | **15x cheaper** |
| **Pro** | 1 min | 50 | $5.00 USDC | Better Uptime ($20) | **4x cheaper** |
| **Enterprise** | 30 sec | Unlimited | $20.00 USDC | AWS Synthetics ($52) | **2.6x cheaper** |

**Compare with AWS CloudWatch Synthetics:** 5-min checks = $51.84/month → **Lighthouse is 50x cheaper**

---

## 🛣️ Roadmap

### Phase 1: MVP (Week 3-4)
- [x] Complete master plan
- [x] Architecture diagrams
- [ ] Rust backend (HTTP monitoring)
- [ ] USDC payment integration (Avalanche Fuji)
- [ ] Discord alerts
- [ ] MongoDB time-series storage
- [ ] Deploy to AWS ECS Fargate

**Deliverable:** Working HTTP monitor with Discord alerts

### Phase 2: Canary Flows (Week 5-6)
- [ ] Python worker setup (Celery)
- [ ] Playwright integration
- [ ] Multi-step scenario support
- [ ] Multi-chain USDC support (Base, Polygon)

**Deliverable:** AWS Synthetics equivalent

### Phase 3: Blockchain Monitoring (Week 7)
- [ ] Native token balance monitoring (AVAX, ETH, MATIC)
- [ ] Facilitator-specific alerts

**Deliverable:** Facilitator balance alerts

### Phase 4: Polish & Launch (Week 8)
- [ ] Multi-channel alerts (Telegram, Email, Slack, SMS)
- [ ] Bilingual UI (English + Spanish)
- [ ] Public status page
- [ ] Community launch

**Deliverable:** Public beta with 10+ external customers

---

## 📊 Business Model Summary

**Revenue Projections (Year 1):**

| Month | Subscribers | Avg Tier | Revenue/Month |
|-------|-------------|----------|---------------|
| 1-3 | 10 | Basic | $2 USDC |
| 4-6 | 50 | Standard | $50 USDC |
| 7-12 | 200 | Standard | $200 USDC |

**Operating Costs:** $57-77/month (EigenCloud or AWS ECS Fargate)

**Break-Even:** Month 5-6 (57-77 subscribers)

**Profitability:** Month 7+ (200+ subscribers = $200/month revenue - $77 costs = **$123 profit**)

---

## ❓ FAQ

**Q: Why USDC instead of GLUE?**
A: USDC is universal ($30B supply), stable, and available on every chain. GLUE is Karmacadabra-specific with limited liquidity. For a product targeting 1000+ Web3 projects, USDC reduces friction.

**Q: Is Lighthouse part of Karmacadabra?**
A: Lighthouse is a **standalone product** developed within the Karmacadabra repository for convenience. It's self-contained with no dependencies on Karmacadabra code. It can be extracted to a separate repo later if needed.

**Q: Why not just use AWS CloudWatch Synthetics?**
A: AWS Synthetics costs $51.84/month for 5-min checks. Lighthouse costs $1/month (51x cheaper). Plus, Lighthouse is crypto-native, supports blockchain monitoring, and has no vendor lock-in.

**Q: When will Lighthouse be production-ready?**
A: MVP in Week 4 (HTTP monitoring + Discord alerts). Full features in Week 8 (canary flows + blockchain + multi-channel alerts).

**Q: Can I self-host Lighthouse?**
A: Yes! Docker Compose one-command deployment (once MVP is ready). Infrastructure is designed to work on any cloud (AWS, GCP, Azure, EigenCloud, Akash, bare metal).

**Q: How is this different from WatchTower?**
A: WatchTower was designed for 53 Karmacadabra agents only (max $3/month revenue). Lighthouse targets the entire Web3 ecosystem (1000+ projects, $200-2000/month potential). See [lighthouse-vs-watchtower.md](./lighthouse-vs-watchtower.md) for full comparison.

---

## 📞 Contact

**Project Lead:** Ultravioleta DAO Core Team
**Status Updates:** Discord #lighthouse channel
**Bug Reports:** GitHub Issues (TBD)
**Feature Requests:** DAO Governance Forum (TBD)

---

## 📄 License

**License:** TBD (likely Apache 2.0 or MIT)
**Copyright:** Ultravioleta DAO
**Open Source:** Yes (once MVP is ready)

---

**Last Updated:** October 28, 2025
**Next Review:** November 15, 2025 (after MVP deployment)
