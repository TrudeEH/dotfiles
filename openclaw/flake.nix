{
  description = "Openclaw development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nix-openclaw, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nix-openclaw.overlays.default ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.openclaw-gateway
          pkgs.openclaw-tools
          pkgs.trash-cli
        ];

        shellHook = ''
          # Start openclaw-gateway if not already running (uses ~/.openclaw config)
          if ! pgrep -f "openclaw-gateway" > /dev/null; then
            echo "Starting openclaw-gateway..."
            openclaw gateway &
            sleep 1
          fi

          xdg-open http://127.0.0.1:18789/ &

          echo ""
          echo "Openclaw development shell"
          echo ""
          echo "Services:"
          echo "  ollama             - http://localhost:11434"
          if pgrep -f "openclaw-gateway" > /dev/null; then
            echo "  openclaw-gateway   - Running"
          fi
          echo ""
          echo "Commands:"
          echo "  ollama list        - List models"
          echo "  ollama run <model> - Chat with a model"
          echo ""
        '';
      };

      # Also expose the packages for direct use
      packages.${system} = {
        default = pkgs.openclaw;
        gateway = pkgs.openclaw-gateway;
        tools = pkgs.openclaw-tools;
      };
    };
}
