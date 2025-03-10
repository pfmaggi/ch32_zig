{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
    yamlfmt.enable = true;
    jsonfmt.enable = true;
    mdformat.enable = true;
    shfmt.enable = true;
    # shellcheck.enable = true;
    zig.enable = true;
  };

  settings = {
    formatter = rec {
      statix = {
        excludes = [
          "**/flake.nix"
        ];
      };
      deadnix = {
        inherit (statix) excludes;
      };
    };
    global.excludes = [
      "*.[Pp][Dd][Ff]" # "*.pdf", case insensitive
      "*.ld"
      "*.png"
      "*.svd"
      "LICENSE"
      "gitignore"
      "template/chip/*.json"
    ];
  };
}
