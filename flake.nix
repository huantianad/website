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
      # (pkgs -> T) -> AttrSet[system: T]
      forAllSystems = function:
        nixpkgs.lib.genAttrs
          [ "x86_64-linux" "aarch64-linux" ]
          (system: function nixpkgs.legacyPackages.${system});
    in
    {
      devShell = forAllSystems (pkgs:
        pkgs.mkShell {
          packages = [ pkgs.hugo ];

          shellHook = ''
            ln -sfT ${hugo-bearcub} themes/hugo-bearcub
          '';
        }
      );
    };
}
