{
  description = "naxce configuration v2";

  inputs = {
    nixpkgs.url = "git+https://github.com/nixos/nixpkgs?ref=nixos-unstable&shallow=1";
    nixpkgs-fonts.url = "git+https://github.com/nixos/nixpkgs?rev=f13ff45afd1bb73e640eaa08a7066dbed07e3238&shallow=1";
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fatest = {
      url = "git+https://github.com/fatumorg/FaTest?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sylvaris = {
      url = "git+https://github.com/fatumorg/Sylvaris?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vice = {
      url = "git+https://github.com/eklonofficial/Vice?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codedesk = {
      url = "git+https://github.com/fatumorg/codedesk?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tempinfocli = {
      url = "git+https://github.com/fatumorg/TempInfoCLI?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    betterfox = {
      url = "git+https://github.com/yokoffing/Betterfox?shallow=1";
      flake = false;
    };
    zen-browser = {
      url = "git+https://github.com/0xc000022070/zen-browser-flake?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    deadlock-plus = {
      url = "git+https://github.com/naxce/deadlock-plus?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-fonts,
      home-manager,
      fatest,
      codedesk,
      deadlock-plus,
      zen-browser,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-fonts = nixpkgs-fonts.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        naxce = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs pkgs-fonts; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.extraSpecialArgs = { inherit inputs pkgs-fonts; };
              home-manager.users.naxce = import ./home.nix;
            }
          ];
        };
      };

      homeConfigurations.naxce = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
}
