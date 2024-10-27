{
  description = "Neorganizer nix shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
          buildToolsVersions = [ "33.0.1" "31.0.0" buildToolsVersion "28.0.3" ];
          platformVersions = [ "34" "33" "28" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
        };
        androidSdk = androidComposition.androidsdk;
      in {
        devShell = with pkgs;
          mkShell rec {
            GRADLE_OPTS =
              "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/31.0.0/aapt2";
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            buildInputs = [ flutter androidSdk jdk17 ];
          };
      });
}
