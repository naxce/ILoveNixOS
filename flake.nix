{
  description = "naxce configuration v2";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-fonts.url = "github:nixos/nixpkgs/f13ff45afd1bb73e640eaa08a7066dbed07e3238";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fatest = {
      url = "github:naxce/FaTest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sylvaris = {
      url = "git+file:///mnt/data/Coding/Linux/Sylvaris";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    /*
      gdoc = {
        url = "github:naxce/GDoc";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    */
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-fonts,
      home-manager,
      fatest,
      #gdoc,
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
