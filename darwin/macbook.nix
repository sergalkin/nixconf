{ config, pkgs, lib, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    input-fonts.acceptsLicense = true;
  };

  environment.systemPackages = with pkgs; [
    neofetch
    iterm2
    alacritty
    mkalias
    obsidian
    karabiner-elements
    vscode
    aerospace
    nerd-fonts.jetbrains-mono
  ];

  homebrew = {
    enable = true;
    brews = [
      "mas"
      "glances"
      "composer"
      "go"
      "golang-migrate"
      "golangci-lint"
      "wrk"
      "shivammathur/php/php@7.4"
      "php@8.1"
      "php@8.2"
      "php@8.3"
      "php@8.4"
    ];
    casks = [
      "iina"
      "font-fira-code"
      "font-monaspace"
      "leader-key"
      "mkalias"
      "aerospace"
    ];
    onActivation.cleanup = "uninstall";
  };

  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  programs.zsh.enable = true;

  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  system.defaults = {
    controlcenter = {
      BatteryShowPercentage = true;
    };

    dock = {
      enable-spring-load-actions-on-all-items = true;
      mouse-over-hilite-stack = true;
      mineffect = "genie";
      orientation = "bottom";
      tilesize = 44;
      magnification = true;
      show-process-indicators = false;
      show-recents = false;
      largesize = 80;
      persistent-apps = [
        "${pkgs.alacritty}/Applications/Alacritty.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Mail.app"
      ];
      persistent-others = [];
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleICUForce24HourTime = true;
      KeyRepeat = 2;
      AppleEnableMouseSwipeNavigateWithScrolls = true;
      AppleEnableSwipeNavigateWithScrolls = true;
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      NSDocumentSaveNewDocumentsToCloud = true;
      "com.apple.keyboard.fnState" = true;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    finder = {
      FXPreferredViewStyle = "clmv";
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      NewWindowTarget = "Home";
      ShowHardDrivesOnDesktop = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    loginwindow = {
      GuestEnabled = false;
    };

    LaunchServices = {
      LSQuarantine = false;
    };

    magicmouse = {
      MouseButtonMode = "TwoButton";
    };

    menuExtraClock = {
      Show24Hour = true;
      ShowDate = 0;
      ShowSeconds = false;
    };
  };

  security.pam.enableSudoTouchIdAuth = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.stateVersion = 6;
}
