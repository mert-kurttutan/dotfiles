# {
#   description = "A simple NixOS flake";

#   inputs = {
#     # NixOS official package source, using the nixos-25.05 branch here
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
#     helix.url = "github:helix-editor/helix/master";
#     home-manager = {
#       url = "github:nix-community/home-manager/release-25.05";
#       # The `follows` keyword in inputs is used for inheritance.
#       # Here, `inputs.nixpkgs` of home-manager is kept consistent with
#       # the `inputs.nixpkgs` of the current flake,
#       # to avoid problems caused by different versions of nixpkgs.
#       inputs.nixpkgs.follows = "nixpkgs";
#     };    
#     # stylix = {
#     #   url = "github:danth/stylix/release-25.05";
#     #   inputs.nixpkgs.follows = "nixpkgs";
#     # };
#   };

#   outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
#     # Please replace my-nixos with your hostname
#     nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
#       system = "x86_64-linux";
#       specialArgs = { inherit inputs; };
#       modules = [
#         # Import the previous configuration.nix we used,
#         # so the old configuration file still takes effect
#         ./configuration.nix
#         # ./home-manager/home.nix
        
#         home-manager.nixosModules.home-manager
#           {
#             home-manager.useGlobalPkgs = true;
#             home-manager.useUserPackages = true;

#             # TODO replace ryan with your own username
#             home-manager.users.oguz = import ./home-manager/home.nix;
#             home-manager.sharedModules = [
#               # Import the home-manager modules we used
#               ./home-manager/home.nix
#               # ./home-manager/modules/stylix.nix
#             ];

#             # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
#           }
#       ];
#     };
#   };
# }





{
  description = "NixOS configuration of Ryan Yin";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  # nixConfig = {
  #   # substituers will be appended to the default substituters when fetching packages
  #   # nix com    extra-substituters = [munity's cache server
  #   extra-substituters = [
  #     "https://nix-community.cachix.org"
  #   ];
  #   extra-trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #   ];
  # };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    helix.url = "github:helix-editor/helix/master";
      # hyprland.url = "github:hyprwm/Hyprland";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
 stylix = {
         url = "github:danth/stylix/release-25.05";
         inputs.nixpkgs.follows = "nixpkgs";
    };
  anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };
  };


  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      nixos = let
        username = "mert";
        user = username;  # Define user variable
        specialArgs = {inherit username inputs user;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";

          modules = [
            ./configuration.nix
            # ./users/${username}/nixos.nix

            home-manager.nixosModules.home-manager
            {
              # home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = inputs // specialArgs;
              home-manager.users.${username} = import ./home-manager/home.nix;
              home-manager.sharedModules = [
              # Import the home-manager modules we used
              ./home-manager/home.nix
              # ./home-manager/modules/stylix.nix
            ];

            }
          ];
        };
    };
  };
}
