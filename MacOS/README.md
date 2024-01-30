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
