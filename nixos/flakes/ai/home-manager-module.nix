{ pkgs, inputs, ... }:

{
  imports = [
    inputs.agent-skills-nix.homeManagerModules.default
  ];

  programs.agent-skills = {
    enable = true;
    sources = {
      anthropics = {
        input = "anthropics-skills";
        subdir = "skills";
      };
      vercel = {
        path = pkgs.runCommand "clean-vercel" { } ''
          mkdir -p $out/skills
          cp -r ${inputs.vercel-skills}/skills/find-skills $out/skills/
        '';
        subdir = "skills";
      };
      bigboss = {
        path = pkgs.runCommand "clean-bigboss" { } ''
          mkdir -p $out/skills
          cp -r ${inputs.bigboss-claude}/.claude/skills/nix-best-practices $out/skills/
        '';
        subdir = "skills";
      };
      lihaoze = {
        path = pkgs.runCommand "clean-lihaoze" { } ''
          mkdir -p $out/skills
          cp -r ${inputs.lihaoze-skills}/skills/nixos-best-practices $out/skills/
        '';
        subdir = "skills";
      };
    };
    skills = {
      enable = [
        "frontend-design"
        "find-skills"
        "nix-best-practices"
        "nixos-best-practices"
      ];
    };
    targets = {
      claude.enable = true;
      codex.enable = true;
      opencode = {
        enable = true;
        dest = "$HOME/.opencode/skills";
      };
      gemini-cli = {
        enable = true;
        dest = "$HOME/.gemini-cli/skills";
      };
      antigravity = {
        enable = true;
        dest = "$HOME/.gemini/antigravity/skills";
      };
    };
  };

  home.packages = with pkgs; [
    codex
    gemini-cli
    antigravity
    lmstudio
    # openclaw
  ];

  home.file.".config/opencode/config.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    plugin = [ "opencode-gemini-auth@latest" ];
  };

  programs.bash.shellAliases = {
    lcodex = "codex --oss";
  };
}
