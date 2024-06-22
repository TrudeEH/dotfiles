# Fix common issues

## WiFi

### Access point requires a password or encryption key - Can't connect.

Edit `/etc/NetworkManager/NetworkManager.conf`.
```diff
+ [device]
+ wifi.scan-rand-mac-address=no
```

