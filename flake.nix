{
description = "Flutter 3.16.7";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  #"github:NixOS/nixpkgs/23.05";
  flake-utils.url = "github:numtide/flake-utils";
};
outputs = { self, nixpkgs, flake-utils }:
  #pkgs.androidenv.licenseAccepted = true;
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          system = "x86_64-linux";
          android_sdk.accept_license = true;
          allowUnfree = true;
          #androidenv.licenseAccepted = true;
          #accept_license = true;
        };
      };

      #buildToolsVersion = "34.0.0-rc4";
      buildToolsVersion = "33.0.2";
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        buildToolsVersions = [ buildToolsVersion "30.0.3" ];
        #buildToolsVersions = [ buildToolsVersion "28.0.3" ];
        platformVersions = [ "31" "33" ];
        abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
        #systemImageTypes = [ "google_apis" ];
        
        extraLicenses = [
          "android-sdk-preview-license"
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "google-gdk-license"
          "intel-android-extra-license"
          "intel-android-sysimage-license"
          "mips-android-sysimage-license"
        ];
      };
      androidSdk = androidComposition.androidsdk;
      #flutter_custom = pkgs.callPackage ./flutter_nix_3_13_0 {};
    in
    {
      devShell =
        with pkgs; mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          CHROME_EXECUTABLE = "/run/current-system/sw/bin/chromium";
          buildInputs = [
            #pkgs.flutter
            #./flutter_nix_3_13_0/default.nix
            #flutter_custom.stable
            androidSdk
            #jdk
            jdk17
            #android-tools
            #android-studio
          ];
        };
    });
}

