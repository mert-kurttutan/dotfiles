# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./gpu.nix
    ];
  hardware.cpu.intel.updateMicrocode = true;
    services.undervolt = {
      enable = true;
      coreOffset = -50;
    };
  hardware.nvidia = {
  # Use open source kernel modules for newer GPUs
    open = true;
    
    # modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    
    # Choose appropriate driver version
    # package = config.boot.kernelPackages.nvidiaPackages.production;
    # use 580 or above as this solves the suspend/resume problem of nvidia 
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "580.65.06";
      sha256_64bit = "sha256-BLEIZ69YXnZc+/3POe1fS9ESN1vrqwFy6qGHxqpQJP8=";
      sha256_aarch64 = "sha256-4CrNwNINSlQapQJr/dsbm0/GvGSuOwT/nLnIknAM+cQ=";
      openSha256 = "sha256-BKe6LQ1ZSrHUOSoV6UCksUE0+TIa0WcCHZv4lagfIgA=";
      settingsSha256 = "sha256-9PWmj9qG/Ms8Ol5vLQD3Dlhuw4iaFtVHNC0hSyMCU24=";
      persistencedSha256 = "sha256-ETRfj2/kPbKYX1NzE0dGr/ulMuzbICIpceXdCRDkAxA=";
    };  

};
  # Enable NVIDIA proprietary drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime = {
    # sync.enable = true;
    # offload = {
    #   enable = true;
    #   # enableOffloadCmd = true;
    # };
    # dedicated
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  boot.kernelPackages = pkgs.linuxPackages;
  # Bootloader.
  boot.kernelParams = [
    "acpi_backlight=native"
    "nvidia-drm.modeset=0"
    "nvidia-drm.fbdev=1"
    # "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    # "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "initcall_blacklist=simpledrm_platform_driver_init"
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
services.geoclue2.enable = true;
services.cpupower-gui.enable = true;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable the COSMIC login manager, COSMIC desktop environment
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # KDE Plasma 6
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;

  services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "trq";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mert = {
    isNormalUser = true;
    description = "mert";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  # yprograms.firefox.enable = true;
programs.firefox = {
  enable = true;
  preferences = {
    # Disable problematic GPU features
    "layers.acceleration.force-enabled" = false;
    "gfx.webrender.enabled" = false;
    "media.ffmpeg.vaapi.enabled" = false;
    
    #  Or alternatively, use software rendering during power changes
    "gfx.canvas.accelerated" = false;
    "layers.gpu-process.enabled" = false;
  };
};
  programs.chromium = {
    enable = true;
    # package = pkgs.brave;
  };
# programs.home-manager.enable = true;
  # Create a wrapped Firefox that sets the environment variable
  nixpkgs.overlays = [
    (self: super: {
      firefox = super.firefox.overrideAttrs (oldAttrs: {
        buildCommand = (oldAttrs.buildCommand or "") + ''
          wrapProgram $out/bin/firefox \
            --set __NV_DISABLE_EXPLICIT_SYNC 1
        '';
      });
    })
  ];
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    gcc
    # linuxPackages.nvidia_x11
    meson
    pkgs.home-manager
    gparted
    devenv  
    fnm
    clang
    rustup
    git
    kitty # required for the default Hyprland config
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    vscode
    brightnessctl
    lshw
    wofi
   pciutils 
   mesa-demos
   neofetch
   lshw
   xorg.xorgserver
   dmidecode
   linuxKernel.packages.linux_zen.turbostat
   linuxKernel.packages.linux_zen.cpupower
   sysbench
brave
 ];
 
 
 environment.sessionVariables = {
  MOZ_ENABLE_WAYLAND = "1";
  MOZ_DISABLE_RDD_SANDBOX = "1";
  # LIBVA_DRIVER_NAME = "nvidia";
  LIBVA_DRIVER_NAME = "nvidia"; 
  # GBM_BACKEND = "nvidia-drm";
  # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  NVD_BACKEND = "direct";
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    BROWSER = "${pkgs.firefox}/bin/firefox";
   # NIXOS_OZONE_WL = "1";
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # systemd.additionalUpstreamSystemUnits = [ "debug-shell.service" ];


}
