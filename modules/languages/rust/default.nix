{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.languages.rust;
in
{
  options.modules.languages.rust = {
    enable = mkEnableOption "Rust programming language development environment";
  };

  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/rust.section.md
    environment.systemPackages = with pkgs; [
      #cargo
      rustup
      rust-analyzer
      #rustc
      #rustfmt
      # cargo-tauri
    ];
  };
}
