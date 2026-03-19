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

  programs.bash.shellAliases = {
    lmcodex = "codex --oss -m qwen3-coder-30b-a3b-instruct";
  };
}
