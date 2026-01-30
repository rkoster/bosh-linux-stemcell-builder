# Helper to request firewall access from bosh-agent
#
# This script provides the permit_monit_access function that can be sourced
# by any process that needs to access the monit API directly.
#
# Usage:
#   source /var/vcap/bosh/etc/monit-access-helper.sh
#   permit_monit_access
#
# Use cases:
#   - The monit wrapper script calls this so monit can access its own API
#   - BOSH-deployed jobs can call this for controlled failover scenarios
#     where they need to monitor or control process lifecycle via monit API

permit_monit_access() {
    # Call agent to open firewall exception for this process's cgroup
    # The agent will detect our cgroup (v1 or v2) and add appropriate nftables rule
    if ! /var/vcap/bosh/bin/bosh-agent firewall-allow monit; then
        echo "Warning: Failed to request monit firewall access" >&2
        # Don't fail - let the caller try to proceed anyway
        # If firewall blocks it, the connection will fail with a clear error
    fi
}
