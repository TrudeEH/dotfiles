#!/bin/sh
upnpc -l | sed -n 's/^[[:space:]]*[0-9]\+\s\+\(TCP\|UDP\)\s\+\([0-9]\+\).*/\1 \2/p' | while read proto port; do
  upnpc -d "$port" "$proto"
done
