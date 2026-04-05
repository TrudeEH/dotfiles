{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.ark
    kdePackages.dolphin
    kdePackages.discover
    kdePackages.dragon
    kdePackages.elisa
    kdePackages.filelight
    kdePackages.gwenview
    kdePackages.khelpcenter
    kdePackages.kinfocenter
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kasts
    kdePackages.kcolorchooser
    kdePackages.kdeconnect-kde
    kdePackages.konsole
    kdePackages.okular
    kdePackages.partitionmanager
    kdePackages.plasma-browser-integration
    kdePackages.plasma-systemmonitor
    kdePackages.print-manager
    kdePackages.sddm-kcm
    kdePackages.spectacle
    wayland-utils
    wl-clipboard
    haruna
    krusader
    okteta
  ];

  home.sessionVariables = {
    EDITOR = "kate";
  };

  xdg.mimeApps = {
    associations.added = {
      "text/x-shellscript" = [ "org.kde.kate.desktop" ];
    };
    defaultApplications = {
      "text/x-shellscript" = [ "org.kde.kate.desktop" ];
    };
  };
}
