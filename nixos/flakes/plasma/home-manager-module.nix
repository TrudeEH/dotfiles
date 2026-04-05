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
    # GNOME gets an SSH agent from gcr. Plasma needs an explicit one.
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  };

  services.ssh-agent.enable = true;

  systemd.user.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
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
