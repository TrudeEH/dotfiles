{ pkgs, ... }:

{
  home.packages = with pkgs; [
    promptfoo
    nmap
    torsocks
  ];
}
