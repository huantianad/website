{ lib
, stdenv
, hugo
, hugo-bearcub
}:

stdenv.mkDerivation {
  pname = "website";
  version = "0.1.0"; # We're running perpetually on ZeroVer!

  src = ./.;

  nativeBuildInputs = [ hugo ];

  buildPhase = ''
    runHook preBuild

    ln -s ${hugo-bearcub} themes/hugo-bearcub
    hugo

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r public $out

    runHook postInstall
  '';
}
