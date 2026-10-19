{ config, lib, ... }:
{
  config =
    lib.mkIf
      (
        config.wsl.enable &&
        (config.wsl.docker-desktop.enable ||
        (config.virtualisation ? podman && config.virtualisation.podman.enable) ||
        (config.virtualisation ? docker && config.virtualisation.docker.enable))
      )
      {
        # Related issues:
        #   - https://github.com/nix-community/NixOS-WSL/issues/433
        #   - https://github.com/nix-community/NixOS-WSL/pull/478
        #
        # By setting `useWindowsDriver` to true, the Nvidia libraries are properly
        # mounted into containers from the Windows host.
        wsl.useWindowsDriver = lib.mkIf (config.hardware ? nvidia-container-toolkit && config.hardware.nvidia-container-toolkit.enable) true;
      };
}
