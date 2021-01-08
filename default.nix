{
  source ? import ./nix/sources.nix,
  system ? builtins.currentSystem,
  overlays ? [],
  crossSystem ? (import source.nixpkgs {}).lib.systems.examples.musl64,
}:
let
  rustChannel = "1.49.0";

  inherit (source) nixpkgs nixpkgs-mozilla cargo2nix;
  pkgs = import nixpkgs {
    inherit system crossSystem;
    overlays =
      let
        rustOverlay = import "${nixpkgs-mozilla}/rust-overlay.nix";
        cargo2nixOverlay = import "${cargo2nix}/overlay";
      in
        [ cargo2nixOverlay rustOverlay ] ++ overlays;
  };

  rustPkgs = pkgs.rustBuilder.makePackageSet' {
    inherit rustChannel;
    packageFun = import ./Cargo.nix;
    localPatterns = [ ''^(src|tests|hello-deps|assets|templates)(/.*)?'' ''[^/]*\.(rs|toml)$'' ];
  };

in rec {
  inherit rustPkgs;

  ci = with builtins; map
    (crate: pkgs.rustBuilder.runTests crate { })
    (attrValues rustPkgs.workspace);

  package = rustPkgs.workspace.hello-deps {};

  shell = pkgs.mkShell {
    inputsFrom = pkgs.lib.mapAttrsToList (_: crate: crate {}) rustPkgs.noBuild.workspace;
    nativeBuildInputs = with rustPkgs; [ cargo rustc rust-src ] ++ [ (import cargo2nix {}).package ];

    RUST_SRC_PATH = "${rustPkgs.rust-src}/lib/rustlib/src/rust/library";
  };
}
