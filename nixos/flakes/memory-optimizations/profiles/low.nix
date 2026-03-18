{ ... }:

{
  # 8 GB and under
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 200;
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 15;
    freeSwapThreshold = 20;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.vfs_cache_pressure" = 200;
    "vm.watermark_boost_factor" = 0;
  };
}
