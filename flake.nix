{
  description = "User's Nix Config with nix-darwin, NixOS, and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, nix-homebrew,  ... }:
  let
    secrets = import ./secrets/git.nix;
    username = secrets.username;  # Будет "ser"
    macbookSystem = "aarch64-darwin";
    desktopSystem = "x86_64-linux";
  in {
    darwinConfigurations.macbook = darwin.lib.darwinSystem {
      system = macbookSystem;
      modules = [
        ./darwin/macbook.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home/home.nix {
            pkgs = nixpkgs.legacyPackages.${macbookSystem};
            inherit username secrets;
          };
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = username;
          };
        }
      ];
    };

    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = desktopSystem;
      modules = [
        ./nixos/desktop.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home/home.nix {
            pkgs = nixpkgs.legacyPackages.${desktopSystem};
            inherit username secrets ;
          };
        }
      ];
    };

    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${desktopSystem};
      modules = [ (import ./home/home.nix {
        pkgs = nixpkgs.legacyPackages.${desktopSystem};
        inherit username secrets;
      }) ];
    };
  };
}
