{
  description = "A flake for my website @ huantian.dev";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    hugo-bearcub = {
      url = "github:huantianad/hugo-bearcub";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, hugo-bearcub }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default =
        pkgs.callPackage ./default.nix { inherit hugo-bearcub; };

      devShell.${system} = pkgs.mkShell {
        packages = [ pkgs.hugo ];

        shellHook = ''
          ln -s ${hugo-bearcub} themes/hugo-bearcub
        '';
      };
    };
}
