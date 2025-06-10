# ===========
# FILE: scripts/rollback.sh
# ==============================================
#!/bin/bash
set -e

ROLLBACK_TO=${1:-blue}

echo "Rolling back to $ROLLBACK_TO environment..."

# Switch traffic back
./scripts/switch-traffic.sh $ROLLBACK_TO

echo "Rollback to $ROLLBACK_TO completed!"
