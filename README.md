# Trude's Dotfiles for Linux and MacOS

**Run `./linux.sh` or `./macos.sh`.**

## Dependencies

### Linux

-   Gnome Console / Terminal (kgx; For some scripts only.)
-   Gnome Desktop
-   Arch or Debian-based distro.

### MacOS

-   None (HomeBrew will be installed if `p` is called.)

## Scripts

### Custom commands

-   `p` - Cross-distro package manager wrapper.
      - Written in bash for Linux, using the system's package manager.
      - Written in ZSH script for MacOS, as a function that calls brew.
-   `m` - Cross-distro maintenance script.
      - Replaced by `p m` on MacOS (for updating MacOS itself).

### Custom scripts used by other programs

-   `p.sh` - For managing packages on Linux systems.
-   `colors.sh` - To add colors to other scripts. Also works on MacOS.

## Todo

-   [ ] Automatically install extensions (GNOME)
    -   Vitals
    -   Dash to Dock
    -   AppIndicator Support
