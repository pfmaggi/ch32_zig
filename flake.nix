{
  description = "A flake for Zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For upgrade use `nix flake update zig zigscient-src`
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    # https://github.com/llogick/zigscient
    zigscient-src = {
      url = "github:llogick/zigscient";
      flake = false;
    };

    # https://github.com/cjacker/wch-openocd
    wch-openocd = {
      url = "github:cjacker/wch-openocd";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs
    , flake-utils
    , ...
    }:
    let
      zlsBinName = "zigscient";
      overlays = [
        (
          _final: prev: with prev; rec {
            zig = inputs.zig.packages.${system}."0.14.0";
            zls = stdenvNoCC.mkDerivation {
              pname = "zigscient";
              version = "${inputs.zigscient-src.shortRev}-${inputs.zigscient-src.lastModifiedDate}";
              src = "${inputs.zigscient-src}";
              nativeBuildInputs = [ zig ];
              phases = [
                "unpackPhase"
                "buildPhase"
                "checkPhase"
              ];
              buildPhase = ''
                mkdir -p .cache
                zig build install --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Dcpu=baseline -Doptimize=ReleaseSafe --prefix $out
              '';
              checkPhase = ''
                zig build test --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Dcpu=baseline
              '';
            };
            minichlink = stdenvNoCC.mkDerivation {
              name = "minichlink";
              src = ./tools/minichlink;
              nativeBuildInputs =
                [
                  zig
                ]
                ++ lib.optionals stdenv.hostPlatform.isLinux [
                  udev
                ]
                ++ lib.optionals stdenv.hostPlatform.isDarwin [
                  apple-sdk_14
                ];
              buildPhase =
                lib.optionalAttrs stdenv.isDarwin ''
                  export NIX_CFLAGS_COMPILE="-iframework $SDKROOT/System/Library/Frameworks -isystem $SDKROOT/usr/include $NIX_CFLAGS_COMPILE"
                  export NIX_LDFLAGS="-L$SDKROOT/usr/lib $NIX_LDFLAGS"
                ''
                + ''
                  mkdir -p .cache
                  zig build --cache-dir $(pwd)/.zig-cache --global-cache-dir $(pwd)/.cache -Dcpu=baseline --prefix $out
                '';
            };
            wch-openocd = stdenv.mkDerivation {
              pname = "wch-openocd";
              version = "2024.11.26";
              src = inputs.wch-openocd;

              nativeBuildInputs = [
                autoconf
                automake
                pkg-config
                libtool
                texinfo
                which
                git
              ];
              buildInputs = [
                hidapi
                libusb1
                tcl
                jimtcl
              ];

              patchPhase = ''
                rm -rf jimtcl src/jtag/drivers/libjaylink
                mkdir -p jimtcl src/jtag/drivers/libjaylink
              '';

              preConfigure = ''
                ./bootstrap nosubmodule
              '';

              configureFlags = [
                "--disable-werror"
                "--disable-internal-jimtcl"
                "--disable-internal-libjaylink"
                "--enable-remote-bitbang"
                "--disable-ftdi"
                "--disable-linuxgpiod"
                "--disable-sysfsgpio"
                "--enable-wlinke"
                "--disable-ch347"
                "--program-prefix=wch-"
              ];

              enableParallelBuilding = true;

              NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isGNU [
                "-Wno-error=cpp"
                "-Wno-error=strict-prototypes"
              ];

              postInstall =
                ''
                  cp $out/share/openocd/scripts/target/wch-riscv.cfg $out/share/openocd/scripts/board/wch-riscv.cfg
                ''
                + lib.optionalString stdenv.isLinux ''
                  mkdir -p "$out/etc/udev/rules.d"
                  rules="$out/share/openocd/contrib/60-openocd.rules"
                  if [ ! -f "$rules" ]; then
                      echo "$rules is missing, must update the Nix file."
                      exit 1
                  fi
                  ln -s "$rules" "$out/etc/udev/rules.d/"
                '';
            };
          }
        )
      ];
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit overlays system; };
        # Eval the treefmt modules from ./treefmt.nix
        treefmtEval = inputs.treefmt.lib.evalModule pkgs ./treefmt.nix;
        inherit (pkgs) zig;
        inherit (pkgs) zls;
        inherit (pkgs) wch-openocd;

        buildInputs =
          with pkgs;
          [
            zig
            zls
            xmlstarlet
            coreutils
            bash
            jq
            git
            clang
            minichlink
            wch-openocd
          ]
          ++ lib.optionals stdenv.isDarwin [
            apple-sdk_14
          ];

        baseShellHook = ''
          export FLAKE_ROOT="$(nix flake metadata | grep 'Resolved URL' | awk '{print $3}' | awk -F'://' '{print $2}')"
        '';
      in
      {
        # run: `nix develop`
        devShells = {
          default = pkgs.mkShell {
            inherit buildInputs;

            shellHook =
              baseShellHook
              + ''
                export HISTFILE="$FLAKE_ROOT/.nix_bash_history"
                sed -i 's/^: [0-9]\{10\}:[0-9];//' $HISTFILE > /dev/null 2>&1
                sed -i '/^#/d' $HISTFILE > /dev/null 2>&1

                export PROJECT_ROOT="$FLAKE_ROOT"
              ''
              + pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin ''
                export NIX_CFLAGS_COMPILE="-iframework $SDKROOT/System/Library/Frameworks -isystem $SDKROOT/usr/include $NIX_CFLAGS_COMPILE"
                export NIX_LDFLAGS="-L$SDKROOT/usr/lib $NIX_LDFLAGS"
              '';
          };

          # Update IDEA paths. Use only if nix installed in whole system.
          # run: `nix develop \#idea`
          idea = pkgs.mkShell {
            inherit buildInputs;

            shellHook = pkgs.lib.concatLines [
              baseShellHook
              ''
                cd "$PROJECT_ROOT"

                if [[ -d "$HOME/Library/Application Support/JetBrains" ]]; then
                  JETBRAINS_PATH="$HOME/Library/Application Support/JetBrains"
                else
                  JETBRAINS_PATH="$HOME/.config/JetBrains"
                fi

                # Find CLion latest path
                IDE_PATH=$(ls -d "$JETBRAINS_PATH"/* | grep -E 'CLion[0-9]+\.[0-9]+')
                echo "IDE_PATH: $IDE_PATH"

                if [[ -f ".idea/zigbrains.xml" ]]; then
                    xmlstarlet ed -L -u '//project/component[@name="ZLSSettings"]/option[@name="zlsPath"]/@value' -v '${zls}/bin/${zlsBinName}' ".idea/zigbrains.xml"
                    xmlstarlet ed -L -u '//project/component[@name="ZigProjectSettings"]/option[@name="toolchainPath"]/@value' -v '${zig}/bin' ".idea/zigbrains.xml"
                    xmlstarlet ed -L -u '//project/component[@name="ZigProjectSettings"]/option[@name="explicitPathToStd"]/@value' -v '${zig}/lib/std' ".idea/zigbrains.xml"
                  else
                    echo "Failed replace paths. File '.idea/zigbrains.xml' not found"
                fi

                if [[ -f "$IDE_PATH/options/mac/embedded-support.xml" ]]; then
                    echo "Replace openocd path"
                    xmlstarlet ed -L -u '//application/component[@name="EmbeddedDevelopment"]/option[@name="openOcdLocation"]/@value' -v '${wch-openocd}/bin/wch-openocd' "$IDE_PATH/options/mac/embedded-support.xml"
                  else
                    echo "Failed replace openocd path. File '$IDE_PATH/options/mac/embedded-support.xml' not found"
                fi

                exit 0
              ''
            ];
          };

          dsview = pkgs.mkShell {
            shellHook =
              pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
                open ${pkgs.dsview}/Applications/DSView.app
              ''
              + pkgs.lib.optionalString pkgs.stdenv.isLinux ''
                ${pkgs.dsview}/bin/dsview
              ''
              + ''
                exit 0
              '';
          };
        };

        # run: `nix fmt`
        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
