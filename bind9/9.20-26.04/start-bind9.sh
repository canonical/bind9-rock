#!/bin/sh
set -e

# Allow arguments to be passed to named via
# --args <service-name> <args>
EXTRA_ARGS="${*}"
  
# Set the foreground flag based on the
# USE_CONFIG_FILE_LOGGING environment variable.
case "${USE_CONFIG_FILE_LOGGING:-false}" in
  [Tt][Rr][Uu][Ee]|1|[Yy][Ee][Ss]|[Yy])
    FOREGROUND_FLAG="-f"
    ;;
  *)
    FOREGROUND_FLAG="-g"
    ;;
esac

exec named $FOREGROUND_FLAG -u $BIND9_USER $EXTRA_ARGS
