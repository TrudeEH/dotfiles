# Trude's Dotfiles

<p align="center">
  <img src="images/logo-circle.png" alt="Logo Circle" width="200" align="middle">
</p>


Welcome to Trude's dotfiles. Here you will find my personal configurations, tools and scripts.
I highly recommend anyone interested to fork the repository and modify any configurations to your liking.
These repository can be used as a base for your own dotfiles.

The 'main' branch is my current configuration, while others serve as an archive of previous setups.

To install my current configuration, run:
```sh
sudo nixos-rebuild switch --flake ./nixos#TrudePC
```

Update NixOS:
```sh
sudo nix flake update --flake ./nixos
```
