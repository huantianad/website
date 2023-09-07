---
title: "Unity3D Development on NixOS with Rider"
description: "A quick start guide for those looking to make games in Unity3D with JetBrains Rider as your editor, all on NixOS!"
date: 2023-09-06T19:32:29-07:00
tags:
  - nix
  - unity3d
  - rider
  - gamedev
---

The joys of Unity... how can such a big and popular game engine be so finnicky? Even if I knew the answer, this probably is not the place to put it. Instead, let's talk about how we can get game-making on the much more pleasant NixOS!

Because we're using this wonderfully esoteric Linux distribution, the recommended installation methods for both Unity Hub and JetBrains Rider will not work. Thankfully, both the packages we'll need are packaged in Nixpkgs and ready for you to use!

Well, mostly. We'll want to do a bit of configuring to make sure that everything is working properly.

## Unity Hub

[Unity Hub](https://unity.com/unity-hub) is the program that Unity3D recommends you use for installing different versions of Unity3D on your systems. The latest version is available in Nixpkgs as [`unityhub`](https://search.nixos.org/packages?channel=unstable&show=unityhub) and can be installed by adding it to your `environment.systemPackages` like any other program:

```nix
{
  environment.systemPackages = [
    pkgs.unityhub
  ];
}
```

Once you have it installed, you can simply launch it, log in, and use it as you would on any other Linux distribution!

This derivation can also be overridden if you need any other system libraries or packages available for your Unity game. For example, I have this in my system configuration for development on [Rhythm Doctor](https://rhythmdr.com/):

```nix
{
  environment.systemPackages = [
    (pkgs.unityhub.override {
      extraPkgs = fhsPkgs: [
        fhsPkgs.harfbuzz
        fhsPkgs.libogg
      ];
    })
  ];
}
```

### OpenSSL Woes

Unity Editor versions before 2022 depend on an older version of OpenSSL that is now marked as insecure. Running any of those versions without any tweaks will give the annoying error message `No usable version of libssl was found` and prevent you from running your game.

The ideal workaround would be to update your Unity editor to a version that works with OpenSSL 3, but if that's not a solution, for now you can manually add the insecure version of OpenSSL to your Unity Hub:

```nix
{
  environment.systemPackages = [
    (pkgs.unityhub.override {
      extraLibs = fhsPkgs; [
        fhsPkgs.openssl_1_1
      ];
    })
  ];
}
```

See [this GitHub issue](https://github.com/NixOS/nixpkgs/issues/205019) for more information.

### Login page not opening?

Unity Hub is packaged in a FHS environment, which causes a bug where `xdg-open` simply does not work. This program is often used to open pages in the users browser, such as what Unity Hub does in order to allow you to sign in. To work around this, we can use the `xdgOpenUsePortal` option to enable an alternate implementation that works:

```nix
{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };
}
```

See [this issue](https://github.com/NixOS/nixpkgs/issues/237581) and [this broader issue](https://github.com/NixOS/nixpkgs/issues/160923) for more info.

## JetBrains Rider

JetBrains recommends using JetBrains Toolbox in order to install Rider, and Toolbox is available in Nixpkgs. I personally have not used this much, but it should work if you prefer the traditional method of installing JetBrains products.

Alternatively, you can use the version of Rider directly provided by Nixpkgs at `jetbrains.rider`. This will require some tweaking to get it to work perfectly with the Unity Editor integration though.

The first step is to add some extra tools and libraries to Rider's `PATH` and `LD_LIBRARY_PATH`, and the second is to modify Rider's file structure to match what the Unity plugin expects:

```nix
let
  extra-path = with pkgs; [
    dotnetCorePackages.sdk_6_0
    dotnetPackages.Nuget
    mono
    msbuild
    # Add any extra binaries you want accessible to Rider here
  ];

  extra-lib = with pkgs;[
    # Add any extra libraries you want accessible to Rider here
  ];

  rider = pkgs.jetbrains.rider.overrideAttrs (attrs: {
    postInstall = ''
      # Wrap rider with extra tools and libraries
      mv $out/bin/rider $out/bin/.rider-toolless
      makeWrapper $out/bin/.rider-toolless $out/bin/rider \
        --argv0 rider \
        --prefix PATH : "${lib.makeBinPath extra-path}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extra-lib}"

      # Making Unity Rider plugin work!
      # The plugin expects the binary to be at /rider/bin/rider,
      # with bundled files at /rider/
      # It does this by going up two directories from the binary path
      # Our rider binary is at $out/bin/rider, so we need to link $out/rider/ to $out/
      shopt -s extglob
      ln -s $out/rider/!(bin) $out/
      shopt -u extglob
    '' + attrs.postInstall or "";
  });
in
{
  environment.systemPackages = [
    rider
  ];
}
```

In addition, you'll need to create a dummy `.desktop` file in `.local/share` to allow the extension to find the application. (This is because this is where JetBrains Toolbox would create a `.desktop` file for the application). You can do this via home-manager if you'd wish:

```nix
# Unity Rider plugin looks here for a .desktop file,
# which it uses to find the path to the rider binary.
{
  environment.systemPackages = [
    rider
  ];

  home-manager.users.huantian.home.file = {
    ".local/share/applications/jetbrains-rider.desktop".source =
      let
        desktopFile = pkgs.makeDesktopItem {
          name = "jetbrains-rider";
          desktopName = "Rider";
          exec = "\"${rider}/bin/rider\"";
          icon = "rider";
          type = "Application";
          # Don't show desktop icon in search or run launcher
          extraConfig.NoDisplay = "true";
        };
      in
      "${desktopFile}/share/applications/jetbrains-rider.desktop";
  };
}
```

## Wrap-up

That's all you should need to get started for making games on NixOS! As always, if there are any issues or improvements that you notice could be made, feel free to let me know.

I'll also link to the relevant [Unity Hub](https://github.com/huantianad/nixos-config/blob/master/modules/dev/unity.nix) and [Rider](https://github.com/huantianad/nixos-config/blob/master/modules/editors/rider.nix) configs in my personal NixOS config for reference.
