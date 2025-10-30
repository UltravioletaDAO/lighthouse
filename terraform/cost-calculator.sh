#!/bin/bash
# ============================================================================
# TimescaleDB AWS Cost Calculator
# ============================================================================
# Usage: ./cost-calculator.sh [instance_type] [volume_gb] [use_spot]
#
# Examples:
#   ./cost-calculator.sh t4g.micro 20 false   # Development
#   ./cost-calculator.sh t4g.small 100 false  # Production Year 1-2
#   ./cost-calculator.sh t4g.medium 500 false # Production Year 3
#   ./cost-calculator.sh t4g.small 50 true    # Staging (spot)
# ============================================================================

set -euo pipefail

# Default values
INSTANCE_TYPE="${1:-t4g.small}"
VOLUME_GB="${2:-100}"
USE_SPOT="${3:-false}"
ENABLE_MONITORING="${4:-true}"

# Pricing (us-east-1, as of October 2025)
declare -A INSTANCE_PRICES=(
  ["t4g.micro"]="0.0084"
  ["t4g.small"]="0.0168"
  ["t4g.medium"]="0.0336"
  ["t4g.large"]="0.0672"
)

EBS_GP3_PRICE="0.08"         # $/GB/month
SNAPSHOT_PRICE="0.05"        # $/GB/month
CLOUDWATCH_ALARM_PRICE="0.10"  # $/alarm/month
CLOUDWATCH_LOGS_PRICE="2.00"   # $/month (estimated)

HOURS_PER_MONTH=730
SPOT_DISCOUNT=0.70  # 70% discount on average

# ============================================================================
# Validate inputs
# ============================================================================

if [[ ! "${INSTANCE_PRICES[$INSTANCE_TYPE]+_}" ]]; then
  echo "Error: Invalid instance type. Supported: ${!INSTANCE_PRICES[@]}"
  exit 1
fi

if [[ $VOLUME_GB -lt 20 ]] || [[ $VOLUME_GB -gt 16384 ]]; then
  echo "Error: Volume size must be between 20 GB and 16 TB"
  exit 1
fi

# ============================================================================
# Calculate costs
# ============================================================================

INSTANCE_HOURLY="${INSTANCE_PRICES[$INSTANCE_TYPE]}"
INSTANCE_MONTHLY=$(echo "$INSTANCE_HOURLY * $HOURS_PER_MONTH" | bc -l)

if [[ "$USE_SPOT" == "true" ]]; then
  INSTANCE_MONTHLY=$(echo "$INSTANCE_MONTHLY * (1 - $SPOT_DISCOUNT)" | bc -l)
fi

STORAGE_MONTHLY=$(echo "$VOLUME_GB * $EBS_GP3_PRICE" | bc -l)

# Snapshots assume 10% of volume size
SNAPSHOT_GB=$(echo "$VOLUME_GB * 0.10" | bc -l)
SNAPSHOT_MONTHLY=$(echo "$SNAPSHOT_GB * $SNAPSHOT_PRICE" | bc -l)

if [[ "$ENABLE_MONITORING" == "true" ]]; then
  # 3 alarms (CPU, disk, status) + logs
  MONITORING_MONTHLY=$(echo "3 * $CLOUDWATCH_ALARM_PRICE + $CLOUDWATCH_LOGS_PRICE" | bc -l)
else
  MONITORING_MONTHLY=0
fi

TOTAL_MONTHLY=$(echo "$INSTANCE_MONTHLY + $STORAGE_MONTHLY + $SNAPSHOT_MONTHLY + $MONITORING_MONTHLY" | bc -l)
TOTAL_YEARLY=$(echo "$TOTAL_MONTHLY * 12" | bc -l)
TOTAL_3YEAR=$(echo "$TOTAL_YEARLY * 3" | bc -l)

# ============================================================================
# Output
# ============================================================================

echo ""
echo "============================================"
echo "TimescaleDB AWS Cost Estimate"
echo "============================================"
echo ""
echo "Configuration:"
echo "  Instance Type:     $INSTANCE_TYPE"
echo "  Volume Size:       ${VOLUME_GB} GB (gp3)"
echo "  Spot Instance:     $USE_SPOT"
echo "  Monitoring:        $ENABLE_MONITORING"
echo ""
echo "============================================"
echo "Cost Breakdown (Monthly)"
echo "============================================"
printf "  Instance:          \$%.2f/month" "$INSTANCE_MONTHLY"
if [[ "$USE_SPOT" == "true" ]]; then
  echo " (spot, 70% discount)"
else
  echo " (on-demand)"
fi
printf "  Storage (gp3):     \$%.2f/month (${VOLUME_GB} GB × \$%.2f/GB)\n" "$STORAGE_MONTHLY" "$EBS_GP3_PRICE"
printf "  Snapshots:         \$%.2f/month (~%.0f GB × \$%.2f/GB)\n" "$SNAPSHOT_MONTHLY" "$SNAPSHOT_GB" "$SNAPSHOT_PRICE"
if [[ "$ENABLE_MONITORING" == "true" ]]; then
  printf "  Monitoring:        \$%.2f/month (3 alarms + logs)\n" "$MONITORING_MONTHLY"
else
  printf "  Monitoring:        \$%.2f/month (disabled)\n" "$MONITORING_MONTHLY"
fi
echo "  ----------------------------------------"
printf "  TOTAL:             \$%.2f/month\n" "$TOTAL_MONTHLY"
echo ""
echo "============================================"
echo "Long-Term Costs"
echo "============================================"
printf "  1 Year:            \$%.2f\n" "$TOTAL_YEARLY"
printf "  3 Years:           \$%.2f\n" "$TOTAL_3YEAR"
echo ""

# ============================================================================
# Comparison with RDS
# ============================================================================

declare -A RDS_PRICES=(
  ["t4g.micro"]="0.016"
  ["t4g.small"]="0.032"
  ["t4g.medium"]="0.064"
  ["t4g.large"]="0.128"
)

if [[ "${RDS_PRICES[$INSTANCE_TYPE]+_}" ]]; then
  RDS_HOURLY="${RDS_PRICES[$INSTANCE_TYPE]}"
  RDS_INSTANCE_MONTHLY=$(echo "$RDS_HOURLY * $HOURS_PER_MONTH" | bc -l)
  RDS_STORAGE_MONTHLY=$(echo "$VOLUME_GB * 0.115" | bc -l)  # RDS storage is $0.115/GB
  RDS_BACKUP_MONTHLY=$(echo "$SNAPSHOT_GB * 0.095" | bc -l)   # RDS backups are $0.095/GB
  RDS_TOTAL_MONTHLY=$(echo "$RDS_INSTANCE_MONTHLY + $RDS_STORAGE_MONTHLY + $RDS_BACKUP_MONTHLY" | bc -l)
  RDS_TOTAL_YEARLY=$(echo "$RDS_TOTAL_MONTHLY * 12" | bc -l)

  SAVINGS_MONTHLY=$(echo "$RDS_TOTAL_MONTHLY - $TOTAL_MONTHLY" | bc -l)
  SAVINGS_YEARLY=$(echo "$RDS_TOTAL_YEARLY - $TOTAL_YEARLY" | bc -l)
  SAVINGS_PERCENT=$(echo "scale=1; ($SAVINGS_MONTHLY / $RDS_TOTAL_MONTHLY) * 100" | bc -l)

  echo "============================================"
  echo "Comparison: EC2 Self-Managed vs RDS"
  echo "============================================"
  printf "  RDS (db.%s):   \$%.2f/month\n" "$INSTANCE_TYPE" "$RDS_TOTAL_MONTHLY"
  printf "  EC2 Self-Managed:    \$%.2f/month\n" "$TOTAL_MONTHLY"
  echo "  ----------------------------------------"
  printf "  Monthly Savings:     \$%.2f (%.0f%% cheaper)\n" "$SAVINGS_MONTHLY" "$SAVINGS_PERCENT"
  printf "  Yearly Savings:      \$%.2f\n" "$SAVINGS_YEARLY"
  echo ""
fi

# ============================================================================
# Capacity Estimates
# ============================================================================

declare -A SUBSCRIPTION_CAPACITY=(
  ["t4g.micro"]="500"
  ["t4g.small"]="2000"
  ["t4g.medium"]="5000"
  ["t4g.large"]="10000"
)

CAPACITY="${SUBSCRIPTION_CAPACITY[$INSTANCE_TYPE]}"
CHECKS_PER_DAY=$(echo "$CAPACITY * 60 * 24" | bc -l)  # 1 check/min per subscription
COST_PER_SUBSCRIPTION=$(echo "scale=4; $TOTAL_MONTHLY / $CAPACITY" | bc -l)

echo "============================================"
echo "Capacity Estimates"
echo "============================================"
echo "  Max Subscriptions: ~$CAPACITY"
printf "  Checks per Day:    ~%.0f\n" "$CHECKS_PER_DAY"
printf "  Cost/Subscription: \$%.4f/month\n" "$COST_PER_SUBSCRIPTION"
echo ""

# ============================================================================
# Recommendations
# ============================================================================

echo "============================================"
echo "Recommendations"
echo "============================================"

if [[ "$INSTANCE_TYPE" == "t4g.micro" ]]; then
  echo "  ✓ Good for: MVP (50-500 subscriptions)"
  echo "  ✓ Upgrade when: CPU > 70% or disk > 80%"
  echo "  → Next step: t4g.small + 100GB"
elif [[ "$INSTANCE_TYPE" == "t4g.small" ]]; then
  echo "  ✓ Good for: Growth (500-2,000 subscriptions)"
  echo "  ✓ Upgrade when: CPU > 70% or 2,000+ subscriptions"
  echo "  → Next step: t4g.medium + 500GB or RDS Multi-AZ"
elif [[ "$INSTANCE_TYPE" == "t4g.medium" ]]; then
  echo "  ✓ Good for: Scale (2,000-5,000 subscriptions)"
  echo "  ⚠ Consider: Migrating to RDS Multi-AZ if revenue > \$5,000/month"
  echo "  → Benefits: Zero ops overhead, automatic failover"
else
  echo "  ✓ Good for: Large scale (5,000+ subscriptions)"
fi

if [[ "$USE_SPOT" == "true" ]]; then
  echo "  ⚠ Spot instances: Acceptable for dev/staging only"
  echo "  → Use on-demand for production (reliability > cost)"
fi

if [[ "$ENABLE_MONITORING" == "false" ]]; then
  echo "  ⚠ Monitoring disabled: Risky for production"
  echo "  → Enable CloudWatch alarms (\$2.30/month)"
fi

if [[ $(echo "$VOLUME_GB < 100" | bc -l) -eq 1 ]]; then
  echo "  → Consider: Increasing volume size if storing > 90 days of data"
fi

echo ""
echo "============================================"
echo "Usage Tips"
echo "============================================"
echo "  • Start small, scale up as needed"
echo "  • Enable TimescaleDB compression (10x storage savings)"
echo "  • Set 90-day retention policy (auto-delete old data)"
echo "  • Monitor actual usage for 1 week before scaling"
echo "  • Use spot for dev/staging (70-90% discount)"
echo "  • Migrate to RDS when revenue justifies zero-ops cost"
echo ""
echo "To deploy this configuration:"
echo "  cd lighthouse/terraform/environments/prod"
echo "  # Update terraform.tfvars:"
echo "  instance_type = \"$INSTANCE_TYPE\""
echo "  volume_size_gb = $VOLUME_GB"
echo "  use_spot_instance = $USE_SPOT"
echo ""
echo "  terraform plan -out=tfplan && terraform apply tfplan"
echo ""
