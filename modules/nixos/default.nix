{ config, pkgs, lib, ... }:

let
  impermanence = builtins.fetchTarball {
    sha256 = "sha256:120775fbfar2x1s5ijkxnvb8p0mmk3dlbq0lzfhsi0csfynp98ki";
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  };

  realtek-kernel-module = pkgs.callPackage ../patches/realtek-kernel-module.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  imports = [ "${impermanence}/nixos.nix" ]; 

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # ACPI patch for ASUS UM3504D harmon/kardon CSC3551 I2C speakers
  # See: https://discourse.nixos.org/t/asus-zenbook-no-sound-output/29326
  boot.loader.grub = {
    # enable = true;
    device = "nodev";
    efiSupport = true;
    # configurationLimit = 10;
    extraConfig = ''
      acpi /ssdt-csc3551.aml
    '';
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.extraModulePackages = [
    (realtek-kernel-module.overrideAttrs (_: {
      patches = [ ../patches/0001-Patch-UM3504D.patch ];
    }))
  ];

  # Enable sound
  # boot.extraModprobeConfig = ''
    # options snd-intel-dspcfg dsp_driver=1
  # '';

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [ "1.1.1.1" ];
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable SDDM login screen
  # services.xserver.displayManager.sddm.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.desktopManager.plasma5.enable = true;

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "colemak";
  };

  # Configure console keymap
  console.keyMap = "jp106";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware = {
    # bluetooth.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };
  security.rtkit.enable = true;
  sound.enable = lib.mkForce false; #disable alsa
  hardware.pulseaudio.enable = lib.mkForce false; #disable pulseAudio
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kai = {
    isNormalUser = true;
    description = "kai";
    extraGroups = [ "audio" "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      git
      htop
      kate
      kitty
    ];
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.kai.useDefaultShell = true;
  


  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "IBMPlexMono" ]; })
  ];

  # Allow experimental features: nix-command, flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
    # this folder is where the files will be stored (don't put it in tmpfs)
  environment.persistence."/nix/persist/system" = { 
    directories = [
      "/etc/nixos"    # bind mounted from /nix/persist/system/etc/nixos to /etc/nixos
      "/etc/NetworkManager"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    acpi
    acpica-tools
    brightnessctl
    dunst
    gcc
    helvum
    hyprland
    hyprpaper
    hyprpicker
    libnotify
    neofetch
    neovim
    networkmanagerapplet
    pavucontrol
    pciutils
    pulseaudio
    rofi-wayland
    ripgrep
    waybar
    wget
    wl-clipboard
  ];

  # ssh.startAgent = true;

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
  system.stateVersion = "23.05"; # Did you read the comment?

}
