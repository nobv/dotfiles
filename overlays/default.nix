# https://github.com/jwiegley/nix-config/blob/master/overlays/30-apps.nix
self: super: {

  installApplication =
    {
      name,
      appname ? name,
      version,
      src,
      description,
      homepage,
      postInstall ? "",
      sourceRoot ? ".",
      ...
    }:
    with super;
    stdenv.mkDerivation {
      name = "${name}-${version}";
      version = "${version}";
      src = src;
      buildInputs = [
        undmg
        unzip
      ];
      sourceRoot = sourceRoot;
      phases = [
        "unpackPhase"
        "installPhase"
      ];
      installPhase = ''
        mkdir -p "$out/Applications/${appname}.app"
        cp -pR * "$out/Applications/${appname}.app"
      ''
      + postInstall;
      meta = with super.lib; {
        description = description;
        homepage = homepage;
        maintainers = with maintainers; [ nobv ];
        platforms = platforms.darwin;
      };
    };

  # JupyterLab = self.installApplication
  #   rec {
  #     name = "JupyterLab";
  #     version = "";
  #     sourceRoot = "JupyterLab.app";
  #     src = super.fetchurl {
  #       name = "JupyterLab-Setup-macOS.dmg";
  #       url = "https://github.com/jupyterlab/jupyterlab-desktop/releases/latest/download/JupyterLab-Setup-macOS.dmg";
  #       sha256 = "sha256-9LDxHlTM/7Wc0Wyw+FU9yvBxtPmKCgi628+B9yUbGKc=";
  #     };
  #     description = ''
  #       A desktop application for JupyterLab, based on Electron.
  #     '';
  #     homepage = "https://github.com/jupyterlab/jupyterlab-desktop";
  #   };

  # ThingsHelper = self.installApplication
  #   rec{
  #     name = "ThingsHelper";
  #     version = "3.39";
  #     sourceRoot = "ThingsMacSandboxHelper.app";
  #     src = super.fetchurl {
  #       name = "ThingsHelper.zip";
  #       url = "https://static.culturedcode.com/things/thingssandboxhelper/${version}/ThingsHelper.zip";
  #       sha256 = "sha256-LdxQkbIWqJ+d96KLpLAp4qafGILjRhrpnjGyti7xndw=";
  #     };
  #     description = "";
  #     homepage = "https://culturedcode.com/things/mac/help/things-sandboxing-helper-things3/";
  #   };
}
