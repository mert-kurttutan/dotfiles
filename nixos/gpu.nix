	{ config, pkgs, ... }: 

{
  services.xserver.videoDrivers = [ "modesetting" ];  # modesetting didn't help
  # boot.blacklistedKernelModules = [ "nouveau" ];  # bbswitch

  
#   boot.kernelParams = [ "acpi_rev_override=5" "i915.enable_guc=2" ];  
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.kernelModules = [ "i915" ];
boot.kernelParams = [ "i915.force_probe=a788" ];
  hardware.graphics = {
    enable = true;
#     driSupport = true;
    extraPackages = with pkgs; [
      # vpl-gpu-rt 
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      # vaapiVdpau
      # libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

}
