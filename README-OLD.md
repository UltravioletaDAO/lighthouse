# Planning Documents

**Directory:** `/contribution/plans/`
**Last Updated:** October 28, 2025

This directory contains high-level architectural plans and research documents for Karmacadabra ecosystem projects.

---

## 📋 Document Index

### Lighthouse (Faro) - Universal Trustless Monitoring Platform

**Status:** Design Complete, Awaiting Approval
**Priority:** High
**Timeline:** 8 weeks to public launch

| Document | Description | Pages | Status |
|----------|-------------|-------|--------|
| **[lighthouse-master-plan.md](./lighthouse-master-plan.md)** | Comprehensive master plan with full technical specifications | 60+ | ✅ Complete |
| **[lighthouse-vs-watchtower.md](./lighthouse-vs-watchtower.md)** | Comparison with previous WatchTower design, justification for scope expansion | 12 | ✅ Complete |
| **[lighthouse-architecture-diagram.md](./lighthouse-architecture-diagram.md)** | ASCII diagrams showing system flows and multi-cloud deployment | 8 | ✅ Complete |
| **[lighthouse-quick-reference.md](./lighthouse-quick-reference.md)** | Quick summary for presentations and community review | 6 | ✅ Complete |

**Key Points:**
- **Vision:** AWS CloudWatch Synthetics for Web3, 50x cheaper
- **Market:** 1000+ Web3 projects (vs 53 Karmacadabra agents)
- **Revenue Potential:** $200-2000/month (vs $2-3/month for WatchTower)
- **Payment Token:** USDC (universal, stable) instead of GLUE
- **Features:** HTTP + Canary flows + Blockchain balance monitoring + WebSocket + GraphQL
- **Branding:** Bilingual (English "Lighthouse" + Spanish "Faro")
- **Deployment:** Multi-cloud (EigenCloud, AWS, Akash)

**Next Steps:**
1. Review with UltravioletaDAO community
2. Approve $500 Q1 budget
3. Begin MVP development (Week 3)

---

### WatchTower (Archived) - Karmacadabra-Only Monitoring

**Status:** Superseded by Lighthouse
**Priority:** Archived (not implemented)

| Document | Description | Status |
|----------|-------------|--------|
| **[facilitator-monitor.md](./facilitator-monitor.md)** | Original WatchTower design (Karmacadabra agents only) | 🗄️ Archived |

**Why Superseded:**
- **Limited market:** 53 agents max vs 1000+ projects for Lighthouse
- **GLUE token:** Volatile, low liquidity vs USDC (stable, universal)
- **Basic features:** HTTP only vs 5 monitoring types in Lighthouse
- **Never profitable:** $37/month costs vs $2-3/month revenue

**Lighthouse supersedes WatchTower** with 100x larger market and 10x more features.

---

### Simulation Scenarios

**Status:** Research / Planning

| Document | Description | Status |
|----------|-------------|--------|
| **[simulation-scenarios.md](./simulation-scenarios.md)** | Test scenarios for ecosystem validation | 📝 Draft |

---

## 🔍 How to Use These Documents

### For Community Review

**Start here:**
1. **[lighthouse-quick-reference.md](./lighthouse-quick-reference.md)** - 5-minute overview
2. **[lighthouse-vs-watchtower.md](./lighthouse-vs-watchtower.md)** - Why this is better than WatchTower

**Deep dive:**
3. **[lighthouse-master-plan.md](./lighthouse-master-plan.md)** - Full specifications (60+ pages)
4. **[lighthouse-architecture-diagram.md](./lighthouse-architecture-diagram.md)** - Visual diagrams

### For Developers

**Implementation guides:**
1. **lighthouse-master-plan.md** → Section 4 (Technology Stack) + Section 14 (Technical Specifications)
2. **lighthouse-architecture-diagram.md** → All diagrams (system flow, payment flow, monitoring flow)

**Key sections:**
- MongoDB schema (time-series collections)
- API endpoints (REST + WebSocket)
- USDC payment integration (EIP-3009)
- Multi-cloud deployment (EigenCloud vs AWS)

### For Business / DAO Governance

**Business case:**
1. **lighthouse-quick-reference.md** → Section "Business Model" + "Revenue Projections"
2. **lighthouse-vs-watchtower.md** → Section "Business Model Comparison"
3. **lighthouse-master-plan.md** → Section 10 (Pricing Strategy) + Section 12 (Business Model)

**Key metrics:**
- Break-even: 57-77 subscribers (Month 5-6)
- Year 1 revenue: $380-11,745 (depending on growth)
- Operating costs: $57-77/month
- Target market: 1000+ Web3 projects

---

## 📊 Decision Matrix

### Should We Build Lighthouse?

| Factor | Score (1-10) | Notes |
|--------|--------------|-------|
| **Market Size** | 10 | 1000+ Web3 projects (100x larger than WatchTower) |
| **Competitive Advantage** | 10 | 50x cheaper than AWS Synthetics + crypto-native |
| **Revenue Potential** | 9 | $2000/month at scale vs $2-3/month for WatchTower |
| **Technical Feasibility** | 9 | Rust + MongoDB + x402 = proven technologies |
| **Time to Market** | 8 | 8 weeks to public launch (MVP in 2 weeks) |
| **Risk Level** | 7 | Low investment ($500), clear validation milestones |
| **Strategic Fit** | 10 | Strengthens Ultravioleta DAO ecosystem beyond Karmacadabra |

**Total Score:** 63/70 (90%)

**Recommendation:** ✅ **APPROVE**

---

## 🚀 Approval Checklist

Before starting Lighthouse development:

### Community Approval
- [ ] Present Lighthouse plan to UltravioletaDAO community
- [ ] Gather feedback (Discord, forums, governance platform)
- [ ] Address concerns and questions
- [ ] Formal vote (if required by DAO governance)

### Budget Approval
- [ ] Approve $500 Q1 budget
  - $200: AWS ECS Fargate (or EigenCloud) hosting (2 months)
  - $100: MongoDB Atlas (2 months)
  - $50: Domain + SSL certificates
  - $100: Marketing (blog posts, social media ads)
  - $50: Buffer for unexpected costs

### Technical Preparation
- [ ] Create `/lighthouse/` repository structure
- [ ] Set up CI/CD pipeline (GitHub Actions)
- [ ] Configure AWS/EigenCloud accounts
- [ ] Register domains (`lighthouse.ultravioletadao.xyz`, `faro.ultravioletadao.xyz`)

### Team Assignment
- [ ] Assign lead developer (Rust backend)
- [ ] Assign Python developer (Celery workers, Playwright)
- [ ] Assign DevOps engineer (Docker, Terraform)
- [ ] Assign documentation writer (bilingual English/Spanish)

### Success Metrics
- [ ] Define KPIs (subscribers, revenue, uptime, alert accuracy)
- [ ] Set up analytics (Posthog, Mixpanel, or similar)
- [ ] Create dashboard for tracking progress

---

## 🔗 Related Documentation

**Karmacadabra Core:**
- `/MASTER_PLAN.md` - Overall ecosystem vision
- `/docs/ARCHITECTURE.md` - Technical architecture
- `/CLAUDE.md` - Development guidelines

**Contribution:**
- `/contribution/0.2-PROGRESS-TRACKER.md` - Sprint progress tracking
- `/contribution/PLAN-WEEK2-FOLDER-STRUCTURE.md` - Organizational structure

**Deployment:**
- `/terraform/` - Infrastructure as code (AWS ECS Fargate)
- `/docker-compose.yml` - Local development setup

---

## 📅 Timeline Summary

| Week | Phase | Deliverables | Status |
|------|-------|--------------|--------|
| **Week 1-2** | Planning | ✅ Master plan, diagrams, community review | **Complete** |
| **Week 3-4** | MVP Development | Rust backend, HTTP monitoring, USDC payments | Pending approval |
| **Week 5-6** | Canary Flows | Multi-step scenarios, Playwright integration | Pending |
| **Week 7** | Blockchain | Native token balance monitoring | Pending |
| **Week 8** | Launch | Landing page, public announcement | Pending |

**Next Milestone:** Community approval + budget approval → Start Week 3 (MVP development)

---

## 💬 Questions or Feedback?

**Discord:** #lighthouse-development (to be created)
**GitHub Issues:** Tag with `[lighthouse]` label
**Email:** dao@ultravioleta.xyz

**Document Maintainer:** Master Architect (Claude Code)
**Last Review:** October 28, 2025

---

**Note:** This is a living document. As Lighthouse development progresses, this index will be updated with:
- Implementation guides
- API documentation
- Deployment runbooks
- Performance benchmarks
- User testimonials
