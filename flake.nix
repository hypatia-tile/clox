{
  description = "Development toolchain for Clox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            meson
            ninja

            clang
            clang-tools
            lldb

            criterion

            pkg-config # required to use criterion
          ];

          shellHook = ''
            echo "Clox dev shell"
            echo "  meson --version"
            echo "  clang --version"
            echo "  clangd --version"
            echo "  clang-format --version"
            echo "  clang-tidy --version"
          '';
        };
      }
    );
}
