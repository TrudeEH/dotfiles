{ pkgs, ... }:

{
  power.ups = {
    enable = true;
    mode = "standalone";

    ups.greencell = {
      driver = "nutdrv_qx";
      port = "auto";
      description = "Green Cell UPS 2000VA";
      directives = [
        "vendorid = 0001"
        "productid = 0000"
      ];
    };

    users.upsmon = {
      passwordFile = "${pkgs.writeText "upsmon-password" "upsmonpass"}";
      upsmon = "primary";
      instcmds = [ "ALL" ];
    };

    upsmon.monitor.greencell = {
      user = "upsmon";
    };
  };
}
