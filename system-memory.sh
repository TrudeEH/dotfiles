#! /bin/sh

awk '
/MemTotal:/ { total=$2 }
/MemAvailable:/ { avail=$2 }
END {
  used=(total-avail)/1024/1024
  total=total/1024/1024
  printf "Real used: %.2f GiB / %.2f GiB\n", used, total
}' /proc/meminfo
