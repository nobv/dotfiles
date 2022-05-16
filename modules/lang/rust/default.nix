{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    cargo
    # rustup
    rust-analyzer
    rustc
    rustfmt
  ];
}
