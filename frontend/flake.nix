# flake.nix
{
  description = "A dev shell for Tauri on NixOS";

  inputs = {
    # You can pin to a specific commit if needed.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      devShell.${system} = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          appimage-run
          pkg-config
          gobject-introspection
          cargo # Rust compiler tool
          cargo-tauri # The cargo plugin to run Tauri commands
          nodejs # Or nodejs_18, nodejs_20, etc.
          wrapGAppsHook
          dpkg
          rpm
          pnpm
        ];

        buildInputs = with pkgs; [
          fuse2
          at-spi2-atk
          atkmm
          cairo
          gdk-pixbuf
          glib
          gtk3
          harfbuzz
          librsvg
          libsoup_3
          pango
          webkitgtk_4_1
          steam-run
        ];

        shellHook = ''
            # Tauri recommends disabling dma-buf in some GPU scenarios.
            export WEBKIT_DISABLE_DMABUF_RENDERER=1

            # Needed on NixOS so that GSettings can find schema definitions at runtime:
            export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS

            # Set OpenSSL-related environment variables

          export OPENSSL_DIR="${pkgs.openssl}"
          export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"

          export TAURI_BUNDLE_LINUX_DEPLOY_PATH="$(command -v linuxdeploy)"
            export PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH

            echo "TAURI_BUNDLE_LINUX_DEPLOY_PATH: $TAURI_BUNDLE_LINUX_DEPLOY_PATH"
            echo "XDG_DATA_DIRS: $XDG_DATA_DIRS"
            echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
            echo "OPENSSL_DIR: $OPENSSL_DIR"
            echo "OPENSSL_LIB_DIR: $OPENSSL_LIB_DIR"
            echo "OPENSSL_INCLUDE_DIR: $OPENSSL_INCLUDE_DIR"
        '';
      };
    };
}
