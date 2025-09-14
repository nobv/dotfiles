{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.development;
in
{
  imports = [
    ./build
    ./cli-tools
    ./data-and-protocol
    ./infrastructure
    ./vcs
  ];

  options.modules.development = {
    cli-tools = mkOption {
      type = types.submodule { };
      default = { };
      description = "CLI tools configuration";
    };

    infrastructure = mkOption {
      type = types.submodule { };
      default = { };
      description = "Infrastructure tools configuration";
    };

    vcs = mkOption {
      type = types.submodule { };
      default = { };
      description = "Version control system tools configuration";
    };

    build = mkOption {
      type = types.submodule { };
      default = { };
      description = "Build tools configuration";
    };

    data-and-protocol = mkOption {
      type = types.submodule { };
      default = { };
      description = "Data and protocol tools configuration";
    };
  };

  config = { };
}
