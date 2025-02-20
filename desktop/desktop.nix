
{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neofetch
    alacritty
    obsidian
    vscode
    i3
  ];

  fonts.packages = with pkgs; [
    fira-code
    monaspace
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager.gdm.enable = true;
  };

  users.users.ser = {  # Обновлено с Siv на ser
    isNormalUser = true;
    home = "/home/ser";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "24.11";
}
