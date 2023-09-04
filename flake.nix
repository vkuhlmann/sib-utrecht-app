{
description = "Flutter 3.10.0";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/23.05";
  flake-utils.url = "github:numtide/flake-utils";
};
outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      buildToolsVersion = "30.0.3";
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        buildToolsVersions = [ buildToolsVersion "33.0.2" ];
        #buildToolsVersions = [ buildToolsVersion "28.0.3" ];
        platformVersions = [ "33" "31" "28" ];
        abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
      };
      androidSdk = androidComposition.androidsdk;
    in
    {
      devShell =
        with pkgs; mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          CHROME_EXECUTABLE = "/run/current-system/sw/bin/chromium";
          buildInputs = [
            pkgs.flutter
            #./flutter_nix_3_13_0/default.nix
            androidSdk
            jdk11
          ];
        };
    });
}

