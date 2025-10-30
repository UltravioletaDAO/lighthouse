# Lighthouse Quick Reference

**Date:** October 28, 2025
**Status:** Design Complete, Awaiting Approval

---

## 🎯 What is Lighthouse?

**Lighthouse (Faro)** = AWS CloudWatch Synthetics for Web3, **50x cheaper**

- Universal monitoring platform (HTTP, Canary flows, Blockchain, WebSocket, GraphQL)
- Crypto-native payments (USDC on Avalanche, Base, Polygon)
- Bilingual (English + Spanish)
- Open-source, self-hostable
- Multi-cloud (EigenCloud, AWS, Akash)

---

## 💰 Pricing (USDC)

| Tier | Price/Month | Checks | Endpoints | Features |
|------|-------------|--------|-----------|----------|
| **Free** | $0.00 | 1-hour | 1 | HTTP, Discord alerts |
| **Basic** | $0.20 | 15-min | 3 | + Telegram alerts |
| **Standard** | $1.00 | 5-min | 10 | + Canary flows, balance monitoring |
| **Pro** | $5.00 | 1-min | 50 | + WebSocket, GraphQL, SMS |
| **Enterprise** | $20.00 | 30-sec | Unlimited | + Chaos testing, white-label, SLA |

**Comparison:**
- AWS Synthetics: $51.84/month (5-min checks) → **50x more expensive**
- Datadog: $5/month per test → **5x more expensive**
- UptimeRobot: $7/month (50 monitors) → **7x more expensive** (but basic features)

---

## 🚀 Key Features

### 1. HTTP Monitoring
- **Configurable status codes:** `[200, 201, 202]` for APIs, `[200, 301, 302]` for web pages
- Response time tracking (DNS, TCP, TLS, TTFB breakdown)
- Body validation (contains, JSONPath, regex, JSON schema)
- Header validation (CORS, security headers)

### 2. Canary Flows (AWS Synthetics Equivalent)
- Multi-step scenarios (test complete workflows)
- Variable extraction (step N → step N+1)
- Playwright browser automation
- Screenshot on failure
- Example: Login → Add to Cart → Checkout

### 3. Blockchain Balance Monitoring
- **Native token balances:** AVAX, ETH, MATIC (for facilitators)
- Alert thresholds (warning + critical)
- Multi-chain support (Avalanche, Base, Polygon)
- **NOT monitoring ERC-20 tokens** (only gas balances)

### 4. WebSocket Monitoring (Pro tier)
- Connection health checks
- Real-time data stream validation
- Latency monitoring

### 5. GraphQL Monitoring (Pro tier)
- Query validation
- Response schema validation
- Latency tracking

---

## 🌍 Bilingual (English + Spanish)

- **Domains:** `lighthouse.ultravioletadao.xyz` (EN) + `faro.ultravioletadao.xyz` (ES)
- **UI strings:** Translated from day 1
- **Alerts:** User chooses language (`"language": "es"` in config)
- **Documentation:** `README.md` ↔ `README.es.md` (synchronized)

---

## 💳 USDC Payment (EIP-3009)

**Why USDC vs GLUE?**
- ✅ Universal (every chain has USDC)
- ✅ Stable ($1 = 1 USDC)
- ✅ Liquid ($30B+ supply)
- ✅ Lower friction (users already hold USDC)

**Supported chains (testnet):**
- Avalanche Fuji: `0x5425890298aed601595a70AB815c96711a31Bc65`
- Base Sepolia: `0x036CbD53842c5426634e7929541eC2318f3dCF7e`
- Polygon Mumbai: `0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97`

**Payment flow:**
1. User signs EIP-3009 authorization (off-chain, gasless)
2. Lighthouse verifies signature (off-chain)
3. Lighthouse executes `transferWithAuthorization` (on-chain)
4. Subscription activated (~2-3 seconds total)

---

## ☁️ Deployment Strategy

**Phase 1 (MVP):** AWS ECS Fargate (known tech, fast deployment)
**Phase 2 (Research):** Evaluate EigenCloud (verifiable monitoring, $15/month)
**Phase 3 (Decision):** Migrate to EigenCloud OR stay on AWS
**Future:** Multi-cloud (EigenCloud primary, AWS fallback, Akash self-hosted)

**EigenCloud benefits:**
- Verifiable monitoring (on-chain proofs via EigenDA)
- Decentralized compute (EigenLayer restaking)
- 25% cheaper than AWS ($15 vs $30/month)
- **Research needed:** Stability, docs, performance

---

## 🗺️ Roadmap

### Phase 1: MVP (2 Weeks)
- HTTP monitoring + Discord alerts + USDC payments
- Deploy to AWS ECS Fargate
- Onboard Karmacadabra agents (first 10 customers)

### Phase 2: Canary Flows (2 Weeks)
- Multi-step scenarios (Playwright)
- Screenshot on failure
- Standard tier (5-min checks)

### Phase 3: Blockchain Monitoring (1 Week)
- Native token balance monitoring
- Multi-chain support (Avalanche, Base, Polygon)
- Pro tier (1-min checks)

### Phase 4: Research & Advanced (2 Weeks)
- Evaluate EigenCloud (parallel deployment)
- Research ChaosChain (defer integration to Phase 5+)
- Multi-channel alerts (Telegram, Email, SMS)

### Phase 5: Polish & Launch (1 Week)
- Landing page (bilingual)
- Public status page
- Marketing (blog, Twitter, Reddit)
- **Public launch 🚀**

---

## 💼 Business Model

### Target Market
1. **Web3 Infrastructure** (RPC providers, indexers, oracles) - $5-20/month
2. **DeFi Protocols** (DEXs, lending, yield) - $1-5/month
3. **NFT Platforms** (marketplaces, gaming) - $1-5/month
4. **DAOs** (governance, treasury monitoring) - $1-5/month
5. **Traditional Web Apps** (crypto-friendly SaaS) - $1-5/month

### Revenue Projections (Year 1)

| Quarter | Users | Paid Users | Revenue/Month | Status |
|---------|-------|------------|---------------|--------|
| Q1 | 100 | 20 | $10 | Subsidized |
| Q2 | 300 | 80 | $60 | Approaching break-even |
| Q3 | 600 | 180 | $180 | **Profitable** |
| Q4 | 1000 | 350 | $438 | Scaling |

**Break-even:** 57-77 subscribers (Month 5-6)
**Operating costs:** $57-77/month (EigenCloud or AWS)
**Year 1 cumulative profit:** +$380 to +$11,745 (depending on growth)

---

## 🔬 Research Action Items

### EigenCloud (Week 6)
- [ ] Check docs: https://docs.eigencloud.xyz
- [ ] Test deployment: Rust + MongoDB compatibility
- [ ] Benchmark: Latency, cost, reliability
- [ ] Decision: Migrate or stay on AWS

### ChaosChain (Future)
- [ ] Research: What is ChaosChain? (experimental L2)
- [ ] Use cases: Chaos testing for monitoring
- [ ] Integration: Phase 4+ (after MVP proven)
- [ ] Alternative: Chaos Toolkit (traditional tool)

### USDC Multi-Chain (Week 7)
- [ ] Test: Polygon bridged USDC (different signature format)
- [ ] Implement: Support Avalanche, Base, Polygon
- [ ] Mainnet: Add mainnet addresses (production)

---

## 📊 Competitive Advantage

**vs AWS CloudWatch Synthetics:**
- ✅ **50x cheaper** ($1 vs $51/month)
- ✅ **Crypto-native** (USDC payments)
- ✅ **Blockchain monitoring** (AWS doesn't have)

**vs Datadog Synthetic Monitoring:**
- ✅ **5x cheaper** ($1 vs $5/month)
- ✅ **Open-source** (audit code)
- ✅ **Self-hosted option** (Docker Compose)

**vs UptimeRobot:**
- ✅ **Canary flows** (UptimeRobot doesn't have)
- ✅ **Blockchain monitoring** (unique feature)
- ✅ **Crypto payments** (no credit card required)

**vs All Competitors:**
- ✅ **Web3-native** (designed for crypto projects)
- ✅ **Multi-cloud** (not locked to AWS/GCP)
- ✅ **Bilingual** (English + Spanish)

---

## ❓ Open Questions

### Technical
1. **Rust vs Python backend?** → Hybrid (Rust core + Python workers)
2. **Playwright mandatory?** → Optional (Pro tier only)
3. **Smart contract registry?** → Optional (not required)
4. **Multi-region deployment?** → Defer to Phase 5+ (after PMF)

### Business
5. **Freemium vs paid-only?** → Freemium (free tier for acquisition)
6. **Annual pricing discount?** → Phase 2+ (after monthly works)
7. **White-label pricing?** → $100/month (Enterprise tier)

### Ecosystem
8. **Integrate with Karmacadabra?** → Optional (can publish agent card)
9. **Accept GLUE as payment?** → Phase 2+ (after USDC works)
10. **DAO governance?** → DAO owns treasury, ops by core team

---

## ✅ Next Steps

### Immediate (Week 1)
1. ✅ Review this plan with UltravioletaDAO community
2. ✅ Approve budget: $500 for Q1
3. ✅ Create `karmacadabra/lighthouse/` directory structure
4. ✅ Start MVP development

### Short-Term (Week 2-4)
1. Deploy MVP to AWS ECS Fargate
2. Onboard first 10 customers (Karmacadabra)
3. Collect feedback, iterate
4. Launch canary flows

### Medium-Term (Month 2-3)
1. Public launch (blog, Twitter, Reddit)
2. Onboard 100 external customers
3. Evaluate EigenCloud
4. Decide: Migrate or stay on AWS

### Long-Term (Month 4-12)
1. Add blockchain monitoring
2. Multi-chain USDC support
3. Enterprise features (white-label, chaos testing)
4. Path to profitability (200+ subscribers)

---

## 📈 Success Metrics

**MVP (Month 1-2):**
- [ ] 15 subscribers (Karmacadabra)
- [ ] 500+ checks executed
- [ ] 0 false positives

**Growth (Month 3-4):**
- [ ] 100 subscribers (50% external)
- [ ] $100/month revenue
- [ ] 5 testimonials

**Scale (Month 5-6):**
- [ ] 500 subscribers
- [ ] $600/month revenue (break-even)
- [ ] 10+ reviews

**Profitability (Month 7-12):**
- [ ] 2000+ subscribers
- [ ] $2000/month revenue
- [ ] 1 partnership (Alchemy, The Graph, etc)
- [ ] 1 enterprise customer

---

## 🎬 Recommendation

**✅ APPROVE LIGHTHOUSE DEVELOPMENT**

**Why:**
1. **100x larger market** (Web3 ecosystem vs Karmacadabra agents)
2. **Path to profitability** (Month 5-6)
3. **Competitive advantage** (50x cheaper, blockchain monitoring)
4. **Low risk** ($500 investment, 2-week MVP)
5. **Strategic value** (strengthens Ultravioleta DAO ecosystem)

**Budget:** $500 for Q1
**Timeline:** 8 weeks to public launch
**Break-even:** Month 5-6 (57-77 subscribers)
**Year 1 Target:** $2000/month revenue, 2000+ users

---

## 📚 Documentation

**Master Plan:** `/contribution/plans/lighthouse-master-plan.md` (60 pages, comprehensive)
**Comparison:** `/contribution/plans/lighthouse-vs-watchtower.md` (WatchTower superseded)
**Architecture:** `/contribution/plans/lighthouse-architecture-diagram.md` (ASCII diagrams)
**This File:** `/contribution/plans/lighthouse-quick-reference.md` (quick summary)

---

**Document Version:** 1.0.0
**Author:** Master Architect (Claude Code)
**Date:** October 28, 2025
**Next Action:** Present to UltravioletaDAO community for approval
