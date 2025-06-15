#!/bin/sh
# Exit on any error
set -e

# Take ownership of the volume mount point
# This ensures the 'minetrack' user can write to it
chown -R minetrack:minetrack /data

# Execute the original command (tini -- node main.js)
exec "$@"
