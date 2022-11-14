{ config, pkgs, lib, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/a0dbe47318/doc/languages-frameworks/rust.section.md
  home.packages = with pkgs; [
    cargo
    # rustup
    rust-analyzer
    rustc
    rustfmt
    # cargo-tauri
  ];
}
