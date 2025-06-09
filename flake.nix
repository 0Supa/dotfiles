{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-wayland,
      home-manager,
      catppuccin,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
      pkgs-wayland = nixpkgs-wayland;
    in
    {
      nixosConfigurations = {
        Kappa = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-bkp-${builtins.toString builtins.currentTime}";

                users.supa = {
                  imports = [
                    ./home.nix
                    catppuccin.homeModules.catppuccin
                  ];
                };
              };
            }
          ];
          specialArgs = {
            inherit pkgs-stable;
            inherit pkgs-wayland;
            inherit inputs;
          };
        };
      };
    };
}
