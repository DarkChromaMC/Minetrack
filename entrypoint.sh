#!/bin/sh
# Exit on any error
set -e

# This script is now run as ROOT
# It now has the permission to change ownership of the /data volume
echo "Taking ownership of /data..."
chown -R minetrack:minetrack /data
echo "Ownership set."

# Now, we step down from root and execute the original CMD as the 'minetrack' user.
# 'gosu' is a lightweight tool for this.
exec gosu minetrack "$@"
