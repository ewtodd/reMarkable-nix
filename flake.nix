{
  description = "reMarkable Desktop App";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        wrapWine = ((import ./wrapWine.nix) { inherit pkgs; }).wrapWine;
        installer = builtins.fetchurl {
          url = "https://downloads.remarkable.com/latest/windows";
          sha256 = "sha256:062d77y09adlmbqyzykdfkcdfamxdqzwdfgz1fcpnk9jcqkk4c87";
        };
        wine = pkgs.wineWowPackages.stagingFull;
        remarkable_bin = wrapWine {
          wine = wine;
          name = "remarkable";
          is64bits = true; # Keep as false since wrapWine.nix has the wine64 path issue
          executable = "$WINEPREFIX/drive_c/reMarkable/reMarkable.exe";
          chdir = "$WINEPREFIX/drive_c/reMarkable";
          firstrunScript = ''
            echo "Installing reMarkable Desktop App..."

            ${wine}/bin/wine ${installer} install \
              --root "C:\\reMarkable" \
              --accept-licenses \
              --default-answer \
              --confirm-command

            sleep 10
            wineserver -w

            if [ -f "$WINEPREFIX/drive_c/reMarkable/reMarkable.exe" ]; then
              echo "Installation successful!"
            else
              echo "ERROR: reMarkable.exe not found"
              exit 1
            fi
          '';
        };
        remarkable_desktop = pkgs.makeDesktopItem {
          name = "reMarkable";
          desktopName = "reMarkable Desktop";
          type = "Application";
          exec = "${remarkable_bin}/bin/remarkable";
        };
        remarkable = pkgs.symlinkJoin {
          name = "remarkable";
          paths = [
            remarkable_bin
            remarkable_desktop
          ];
        };
      in
      {
        packages = {
          remarkable = remarkable;
          default = remarkable;
        };
      }
    );
}
