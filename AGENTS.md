Use idiomatic nix.

Before making changes, read the appropriate entries of the following manuals:
- man configuration.nix
- man home-configuration.nix

Do not read the entire manual at once, instead search only for what you need.

After editing nix configurations, always run  `nix flake check nixos/` to check for errors.
Do NOT attempt to rebuild the system, let the user handle that.
