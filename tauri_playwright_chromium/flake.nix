# flake.nix
{
  description = "A dev shell for Tauri on NixOS";

  inputs = {
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

      texter =
        {
          lib,
          stdenv,
          fetchFromGitHub,
          rustPlatform,
          pkg-config,
          openssl,
          darwin,
        }:
        rustPlatform.buildRustPackage rec {
          pname = "texter";
          version = "0.1.0";

          src = fetchFromGitHub {
            owner = "jichen-jay";
            repo = "texter";
            rev = "6bdf3ae9544f2a9515ef93481802944d92977b75";
            sha256 = "1ay72424rg8b1650bkf6phkllmij8fz2pvf3a7x4lypr93pyb79m";
          };

          cargoLock = {
            lockFile = ./texter/Cargo.lock;
            outputHashes = {
            };
          };
          nativeBuildInputs = [ pkg-config ];

          buildInputs = [ openssl ];

          doCheck = false;

          meta = with lib; {
            description = "Texter package";
            homepage = "https://github.com/jichen-jay/texter";
            license = licenses.mit;
            maintainers = [ ];
          };
        };

    in
    {
      packages.${system}.texter = pkgs.callPackage texter { };

      devShell.${system} = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          appimage-run
          pkg-config
          gobject-introspection
          cargo
          rustc
          nodejs_20
          pnpm
          chromium
          playwright-test
          playwright-driver
          playwright-driver.browsers
          wrapGAppsHook
          (pkgs.callPackage texter { })
        ];

        buildInputs = with pkgs; [
          fuse2
          atk
          at-spi2-core
          cairo
          cups
          dbus
          expat
          gtk3
          libdrm
          mesa
          nspr
          nss
          pango
          xorg.libX11
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXrandr

          gdk-pixbuf # Image rendering for GTK apps.
          harfbuzz # Text shaping.
          librsvg # SVG rendering.
          libsoup_3 # HTTP library used by WebKitGTK.
          webkitgtk_4_1 # Required for Tauri's WebView.
        ];

        shellHook = ''
          export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
          export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
          export CHROMIUM_PATH=${pkgs.chromium}/bin/chromium

          # Disable dma-buf renderer for WebKit on certain GPUs.
          export WEBKIT_DISABLE_DMABUF_RENDERER=1

          # GSettings schema definitions at runtime (required for GTK apps).
          export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS

          # OpenSSL environment variables for building Tauri apps.
          export OPENSSL_DIR="${pkgs.openssl}"
          export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"

          # PKG_CONFIG_PATH for OpenSSL and other libraries.
          export PKG_CONFIG_PATH=${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH

          # Set Tauri's Linux deploy path.
          export TAURI_BUNDLE_LINUX_DEPLOY_PATH="$(command -v linuxdeploy)"

          echo "Environment setup complete:"
          echo "PLAYWRIGHT_BROWSERS_PATH: $PLAYWRIGHT_BROWSERS_PATH"
          echo "XDG_DATA_DIRS: $XDG_DATA_DIRS"
        '';
      };
    };
}
