---
title: Common Configuration Mistakes
impact: HIGH
impactDescription: Prevents the most frequently made configuration errors
tags: mistakes,pitfalls,errors,checklist
---


## Why This Matters

Understanding common mistakes helps avoid them, saving time and preventing configuration errors.

## Mistake 1: Overlay in Wrong Location

### Symptom
Package not found even though overlay is defined.

### Cause
Overlay defined in `home.nix` when `useGlobalPkgs = true`.

### Solution
Move overlay to host's home-manager configuration block.

```nix
# ❌ WRONG
# home-manager/home.nix
{
  nixpkgs.overlays = [ inputs.overlay.overlays.default ];
}

# ✅ CORRECT
# hosts/home/default.nix
{
  home-manager.nixpkgs.overlays = [ inputs.overlay.overlays.default ];
}
```

**See:** [overlay-scope.md](overlay-scope.md)

## Mistake 2: Forgetting specialArgs

### Symptom
`undefined variable 'inputs'` error.

### Cause
Not passing `inputs` via `specialArgs`.

### Solution
Add `specialArgs = { inherit inputs; }`.

```nix
# ❌ WRONG
outputs = { self, nixpkgs, home-manager }:
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    modules = [ ./hosts/myhost ];
  };
}

# ✅ CORRECT
outputs = { self, nixpkgs, home-manager, ... }@inputs:
{
  nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ./hosts/myhost ];
  };
}
```

**See:** [flakes-structure.md](flakes-structure.md)

## Mistake 3: Editing hardware-configuration.nix

### Symptom
Hardware changes lost after running `nixos-generate-config`.

### Cause
Manually editing generated file.

### Solution
Put custom config in `default.nix`, not `hardware-configuration.nix`.

```nix
# ❌ WRONG: Editing hardware-configuration.nix
# hosts/laptop/hardware-configuration.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  # My custom kernel parameters (will be lost!)
  boot.kernelParams = [ "intel_iommu=on" ];

  # Generated hardware config...
}

# ✅ CORRECT: Custom config in default.nix
# hosts/laptop/default.nix
{
  imports = [ ./hardware-configuration.nix ];

  # Custom kernel parameters (safe!)
  boot.kernelParams = [ "intel_iommu=on" ];
}
```

**See:** [host-organization.md](host-organization.md)

## Mistake 4: Duplicate Package Declarations

### Symptom
Package installed multiple times or conflicts.

### Cause
Same package in both system and Home Manager config.

### Solution
Install in appropriate location only.

```nix
# ❌ WRONG: Same package in both places
# hosts/base.nix
environment.systemPackages = with pkgs; [ firefox ];

# home-manager/home.nix
home.packages = with pkgs; [ firefox ];  # Duplicate!

# ✅ CORRECT: Choose one location
# User apps in Home Manager
home.packages = with pkgs; [ firefox ];
```

**See:** [package-installation.md](package-installation.md)

## Mistake 5: Not Following nixpkgs

### Symptom
Slow builds, inconsistent packages.

### Cause
Multiple independent nixpkgs instances.

### Solution
Use `.follows` for dependency inputs.

```nix
# ❌ WRONG: Independent nixpkgs
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager/release-25.05";
  # home-manager will use its own nixpkgs!
};

# ✅ CORRECT: Follow nixpkgs
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager/release-25.05";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};
```

**See:** [flakes-structure.md](flakes-structure.md)

## Mistake 6: Mixing System and User Concerns

### Symptom
User-specific config in system files or vice versa.

### Cause
Not understanding NixOS vs Home Manager responsibilities.

### Solution
System config in NixOS, user config in Home Manager.

```nix
# ❌ WRONG: User config in system
# hosts/base.nix
{
  # User's git config (should be in Home Manager)
  programs.git = {
    enable = true;
    userName = "john";
    userEmail = "john@example.com";
  };
}

# ✅ CORRECT: User config in Home Manager
# home-manager/home.nix
{
  programs.git = {
    enable = true;
    userName = "john";
    userEmail = "john@example.com";
  };
}
```

**See:** [package-installation.md](package-installation.md)

## Mistake 7: Forgetting to Rebuild

### Symptom
Changes don't appear after editing config.

### Cause
Editing config but not running rebuild.

### Solution
Always rebuild after config changes.

```bash
# After editing NixOS config
sudo nixos-rebuild switch --flake .#hostname

# After editing Home Manager config (standalone)
home-manager switch --flake .#hostname

# When using NixOS-integrated Home Manager
sudo nixos-rebuild switch --flake .#hostname
```

## Mistake 8: Overriding systemPackages Multiple Times

### Symptom
Some packages disappear after adding others.

### Cause
Multiple `environment.systemPackages` assignments.

### Solution
Use single list or mkBefore/mkAfter.

```nix
# ❌ WRONG: Multiple assignments
environment.systemPackages = with pkgs; [ vim git ];
environment.systemPackages = with pkgs; [ htop ];  # Overwrites!

# ✅ CORRECT: Single list
environment.systemPackages = with pkgs; [
  vim
  git
  htop
];

# ✅ ALSO CORRECT: Use mkBefore/mkAfter
environment.systemPackages = with pkgs; [ vim git ];
environment.systemPackages = mkAfter [ pkgs.htop ];
```

## Mistake 9: Hardcoding Paths

### Symptom
Config breaks on different machines.

### Cause
Using absolute paths instead of Nix paths.

### Solution
Use relative paths or Nix constructs.

```nix
# ❌ WRONG: Absolute path
{ pkgs, ... }:
{
  environment.systemPackages = [
    "/home/john/my-app/bin/my-app"  # Only works for john!
  ];
}

# ✅ CORRECT: Use Nix package
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.my-app ];
}

# ✅ OR: Use path from flake
{ ... }:
{
  environment.systemPackages = [
    (pkgs.callPackage ./local-packages/my-app { })
  ];
}
```

## Mistake 10: Not Using Flake References

### Symptom
Can't use packages from flake inputs.

### Cause
Not passing inputs or using wrong reference.

### Solution
Use `inputs.*` syntax.

```nix
# ❌ WRONG: Trying to use input package
{ pkgs, ... }:
{
  environment.systemPackages = [
    unfire-overlay  # Where does this come from?
  ];
}

# ✅ CORRECT: Use input reference
{ pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.unfire-overlay.packages.${pkgs.system}.default
  ];
}
```

## Quick Checklist

Before committing config changes:

- [ ] Overlay in correct location for useGlobalPkgs setting
- [ ] inputs passed via specialArgs if needed
- [ ] Not editing hardware-configuration.nix
- [ ] No duplicate package declarations
- [ ] Following nixpkgs for dependency inputs
- [ ] System config separate from user config
- [ ] Tested with rebuild
- [ ] Using Nix paths, not absolute paths
- [ ] Correct input references for flake packages
