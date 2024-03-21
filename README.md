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

## MacOS Commands (built-in)

**Password-protected Zip:** 
```sh
zip -e protected.zip /file/to/protect/
```

**Remove dotfiles:** 
```sh
dot_clean .
```

**Show all files in finder:** 
```sh
defaults write com.apple.Finder AppleShowAllFiles 1
```

**Search using Spotlight:** 
```sh
mdfind "file name”
```

**Rebuild Spotlight index:** 
```sh
mdutil -E
```

**Turn off Spotlight indexing:** 
```sh
dutil -i off
```

**Repair Disk permissions:** 
```sh
sudo /usr/libexec/repair_packages --repair --standard-pkgs --volume /
```

**Generate SHA-1 digest of a file:** 
```sh
/usr/bin/openssl sha1 download.dmg
```

**Disable sleep temporarily:** 
```sh
caffeinate
```

**Open multiple instances of a program:** 
```sh
open multiple instances open -n /Applications/Safari.app/
```

**Check network speed:** 
```sh
networkQuality
```

**Convert files (txt, html, rtf, rtfd, doc, docx):** 
```sh
textutil -convert html journal.doc
```
