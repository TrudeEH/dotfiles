{ ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;

  users.groups.libvirtd.members = [ "trude" ];
  users.groups.kvm.members = [ "trude" ];
}
