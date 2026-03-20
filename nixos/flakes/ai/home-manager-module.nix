{ pkgs, ... }:

{
  home.packages = with pkgs; [
    codex
    gemini-cli
    antigravity
    opencode-desktop
    lmstudio
    openclaw
  ];

  home.file.".config/opencode/config.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    plugin = [ "opencode-gemini-auth@latest" ];
  };

  programs.bash.shellAliases = {
    lmcodex = "codex --oss -m qwen3-coder-30b-a3b-instruct";
  };
}
