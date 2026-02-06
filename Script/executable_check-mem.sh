
#!/bin/sh

[ -z "$1" ] && {
    echo "Usage: $(basename "$0") <process-regex>"
    exit 1
}

# Exclude smem and this script from matches
exec smem \
  -P "^(?!.*(smem|check-mem\.sh)).*$1" \
  -k -t -s uss -r
