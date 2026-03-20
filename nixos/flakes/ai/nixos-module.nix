{ lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev:
      let
        matrixCryptoLib =
          {
            x86_64-linux = {
              fileName = "matrix-sdk-crypto.linux-x64-gnu.node";
              src = prev.fetchurl {
                url = "https://github.com/matrix-org/matrix-rust-sdk-crypto-nodejs/releases/download/v0.4.0/matrix-sdk-crypto.linux-x64-gnu.node";
                hash = "sha256-cHjU3ZhxKPea/RksT2IfZK3s435D8qh1bx0KnwNN5xg=";
              };
            };
          }
          .${prev.stdenv.hostPlatform.system}
            or null;
      in
      {
        openclaw = prev.openclaw.overrideAttrs (old:
          lib.optionalAttrs (matrixCryptoLib != null) {
            postInstall =
              (old.postInstall or "")
              + ''
                found=0
                for cryptoDir in "$out"/lib/openclaw/node_modules/.pnpm/@matrix-org+matrix-sdk-crypto-nodejs@*/node_modules/@matrix-org/matrix-sdk-crypto-nodejs; do
                  if [ ! -d "$cryptoDir" ]; then
                    continue
                  fi

                  found=1
                  install -Dm444 ${matrixCryptoLib.src} "$cryptoDir/${matrixCryptoLib.fileName}"
                done

                if [ "$found" -eq 0 ]; then
                  echo "openclaw matrix crypto package directory not found" >&2
                  exit 1
                fi
              '';
          });
      })
  ];

  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "openclaw"
    ];

  systemd.services.openclaw = {
    description = "OpenClaw Gateway";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HOME = "/home/trude";
    };
    serviceConfig = {
      Type = "simple";
      User = "trude";
      Group = "trude";
      WorkingDirectory = "/home/trude";
      ExecStart = "${pkgs.openclaw}/bin/openclaw gateway run";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  networking.firewall.allowedTCPPorts = [ 11434 ]; # LMStudio
}
