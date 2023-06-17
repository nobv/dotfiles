# https://github.com/jwiegley/nix-config/blob/master/overlays/30-apps.nix
self: super: {

  installApplication =
    { name
    , appname ? name
    , version
    , src
    , description
    , homepage
    , postInstall ? ""
    , sourceRoot ? "."
    , ...
    }:
      with super; stdenv.mkDerivation {
        name = "${name}-${version}";
        version = "${version}";
        src = src;
        buildInputs = [ undmg unzip ];
        sourceRoot = sourceRoot;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p "$out/Applications/${appname}.app"
          cp -pR * "$out/Applications/${appname}.app"
        '' + postInstall;
        meta = with super.lib; {
          description = description;
          homepage = homepage;
          maintainers = with maintainers; [ nobv ];
          platforms = platforms.darwin;
        };
      };

  Morgen = self.installApplication
    rec {
      name = "Morgen";
      version = "2.7.3";
      sourceRoot = "Morgen.app";
      src = super.fetchurl {
        name = "Morgen ${version}-arm64.dmg";
        url = "https://dl.todesktop.com/210203cqcj00tw1/mac/dmg/arm64";
        sha256 = "sha256-z4//vNzeZ8nUXM+Vd4SJkPE+u5IA/JAK0SX7EsYk5L4=";
      };
      description = ''
        Make the most out of your time
      '';
      homepage = "https://morgen.so";
    };

  # HTTPie = self.installApplication
  #   rec {
  #     name = "HTTPie";
  #     version = "2023.1.0";
  #     sourceRoot = "HTTPie.app";
  #     src = super.fetchurl {
  #       name = "HTTPie-${version}-arm64.dmg";
  #       url = "https://github.com/httpie/desktop/releases/download/v${version}/HTTPie-${version}-arm64.dmg";
  #       sha256 = "sha256-dYXWnOf72RLoD4AY1EAVZ7231j59zHjlFab9tmKS1Mk=";
  #     };
  #     description = ''
  #       HTTPIE WEB & DESKTOP APP
  #     '';
  #     homepage = "https://httpie.io/product";
  #   };
  #
  # ClickUp = self.installApplication
  #   rec {
  #     name = "ClickUp";
  #     version = "3.2.8";
  #     sourceRoot = "ClickUp.app";
  #     src = super.fetchurl {
  #       name = "ClickUp ${version}-arm64.dmg";
  #       url = "https://desktop.clickup.com/mac/dmg/arm64";
  #       sha256 = "sha256-0/lBxTYNl3Yfxgcm/f7zEfZUeW7TZFBaddmqpsHrKvs=";
  #     };
  #     description = ''
  #       One app to replace them all.
  #       All of your work in one place: Tasks, Docs, Chat, Goals, & more.
  #     '';
  #     homepage = "https://clickup.com/";
  #   };

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

  #Spark =
  #  let
  #    currentVersion = {
  #      major = "3";
  #      minor = "3";
  #      patch = "3";
  #      build = "42968";
  #    };

  #    semanticVerion = with currentVersion; "${major}.${minor}.${patch}";
  #    currentVersionStr = with currentVersion; "${major}.${minor}.${patch}.${build}";
  #  in
  #  self.installApplication
  #    rec {
  #      name = "Spark Desktop";
  #      version = currentVersionStr;
  #      sourceRoot = "Spark Desktop.app";
  #      src = super.fetchurl {
  #        name = "Spark Desktop ${semanticVerion}-universal.dmg";
  #        url = "https://downloads.sparkmailapp.com/Spark3/mac/dist/${version}/Spark.dmg";
  #        sha256 = "sha256-DUYSqQhwXR0tMbHQXf6GOrl+7Hs3PGciYId8SdltV2Y=";
  #      };
  #      description = ''
  #        Smart. Focused. Email.
  #        Fast, cross-platform email designed to filter out the noise - so you can focus on what's important.
  #      '';
  #      homepage = "https://sparkmailapp.com/";
  #    };

  # Rize = self.installApplication
  #   rec {
  #     name = "Rize";
  #     version = "0.18.15";
  #     sourceRoot = "Rize.app";
  #     src = super.fetchurl {
  #       name = "rize-${version}-arm64.dmg";
  #       url = "https://app.rize.io/downloads/macos?arch=arm64&pid=rJUE1wFg8AzpZuarzCAFRZp7";
  #       sha256 = "sha256-GrL6OlwFfA/ZkrTxNooVQ5oyYauEQqQEHA05Vp+DNb4=";
  #     };
  #     description = ''
  #       Maximize Your Productivity
  #       Rize is a smart time tracker that improves your focus and helps you build better work habits.
  #     '';
  #     homepage = "https://rize.io/";
  #
  #   };
  #
  ThingsHelper = self.installApplication
    rec{
      name = "ThingsHelper";
      version = "3.33";
      sourceRoot = "ThingsMacSandboxHelper.app";
      src = super.fetchurl {
        name = "ThingsHelper.zip";
        url = "https://static.culturedcode.com/things/thingssandboxhelper/${version}/ThingsHelper.zip";
        sha256 = "sha256-LdxQkbIWqJ+d96KLpLAp4qafGILjRhrpnjGyti7xndw=";
      };
      description = "";
      homepage = "https://culturedcode.com/things/mac/help/things-sandboxing-helper-things3/";
    };
}
