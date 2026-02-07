# nix develop
{
  description = "OpenClaw dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "openclaw-shell";

          buildInputs = with pkgs; [
            nodejs_22
            git
            curl
            cmake
          ];

          shellHook = ''
            echo "🦞 OpenClaw"
            echo ""

            # Set up local npm prefix to avoid permission issues
            export NPM_CONFIG_PREFIX="$PWD/.npm-global"
            export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

            # Ensure the prefix directory exists
            mkdir -p "$NPM_CONFIG_PREFIX/bin"

            # Install openclaw if not already installed
            if ! command -v openclaw &> /dev/null; then
              echo "📦 Installing OpenClaw..."
              npm install -g openclaw
            fi

            echo ""
            echo "Run 'openclaw gateway' to start the gateway"
            echo ""
          '';
        };
      }
    );
}
