{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, lib, ... }: {
      
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [ neovim
	  tmux
 	  iterm2
	  alacritty
	  mkalias
	  git
	  obsidian
	  fzf
          htop
	  zoxide
	  fd
	  eza
	  du-dust
	  ripgrep
	  jq
	  wget
	  yq
	  tree
	  zsh-syntax-highlighting
	  inetutils
	  zsh
	  vim
	  karabiner-elements
	  vscode
	  aerospace
	  #raycast
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
         # "the-unarchiver"
	  "iina"
	  "font-fira-code"
	  "font-monaspace"
	  "leader-key"
	];
	masApps = {
	  #"Yoink" = 457622435;
	};
	onActivation = {
	  autoUpdate = true;
	  upgrade = true;
	  cleanup = "zap";
	};
      };

      fonts.packages = [
	pkgs.nerd-fonts.jetbrains-mono
      ];

      system.activationScripts.applications.text = let
	env = pkgs.buildEnv {
	  name = "system-applications";
	  paths = config.environment.systemPackages;
	  pathsToLink = "/Applications";
	};
      in
	pkgs.lib.mkForce ''
	  # Set up applications.
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
      
      
      system = {
	defaults = {
	  
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
      };

      nix = {
	optimise.automatic = true;
#	auto-optimise-store = true;

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
      
      nixpkgs = {
        config = {
	  allowUnfree = true;
	  input-fonts.acceptsLicense = true;
	};
      };

      


      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.enableSudoTouchIdAuth = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [ 
	configuration
	nix-homebrew.darwinModules.nix-homebrew
	{
	  nix-homebrew = {
	    enable = true;
	    enableRosetta = true;
	    user = "ser";
	  };
	} 
      ];
    };
  };
}
