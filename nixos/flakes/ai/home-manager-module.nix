{ pkgs, ... }:

{
  home.packages = with pkgs; [
    codex
    opencode-desktop
    lmstudio
  ];

  programs.bash.shellAliases = {
    lmcodex = "codex --oss -m qwen3-coder-30b-a3b-instruct";
  };
}
