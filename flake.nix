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

    zigscient-src = {
      url = "github:llogick/zigscient";
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
            zig = inputs.zig.packages.${system}.master;
            zls = stdenvNoCC.mkDerivation {
              name = "zigscient";
              version = "master";
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

        buildInputs =
          with pkgs;
          [
            zig
            zls
            xmlstarlet
            coreutils
            bash
            git
            clang
            minichlink
          ]
          ++ lib.optionals stdenv.isDarwin [
            apple-sdk_14
          ];
      in
      {
        # run: `nix develop`
        devShells = {
          default = pkgs.mkShell {
            inherit buildInputs;

            shellHook =
              ''
                export FLAKE_ROOT=$(nix flake metadata | grep 'Resolved URL' | awk '{print $3}' | awk -F'://' '{print $2}')
                export HISTFILE="$FLAKE_ROOT/.nix_bash_history"
                sed -i 's/^: [0-9]\{10\}:[0-9];//' $HISTFILE
                sed -i '/^#/d' $HISTFILE
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
              ''
                if [[ -f .idea/zigbrains.xml ]]; then
                  xmlstarlet ed -L -u '//project/component[@name="ZLSSettings"]/option[@name="zlsPath"]/@value' -v '${zls}/bin/${zlsBinName}' .idea/zigbrains.xml
                  xmlstarlet ed -L -u '//project/component[@name="ZigProjectSettings"]/option[@name="toolchainPath"]/@value' -v '${zig}/bin' .idea/zigbrains.xml
                  xmlstarlet ed -L -u '//project/component[@name="ZigProjectSettings"]/option[@name="explicitPathToStd"]/@value' -v '${zig}/lib/std' .idea/zigbrains.xml
                fi

                exit 0
              ''
            ];
          };
        };

        # run: `nix fmt`
        formatter = treefmtEval.config.build.wrapper;
      }
    );
}
