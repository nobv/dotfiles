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
      version = "2.5.5";
      sourceRoot = "Morgen.app";
      src = super.fetchurl {
        name = "Morgen ${version}-arm64.dmg";
        url = "https://dl.todesktop.com/210203cqcj00tw1/mac/dmg/arm64";
        sha256 = "sha256-55SEtAHEbPEvo8WLGxDYrIIZr1f0/22po5ZdHugQEWs=";
      };
      description = ''
        Make the most out of your time
      '';
      homepage = "https://morgen.so";
    };

  HTTPie = self.installApplication
    rec {
      name = "HTTPie";
      version = "2022.8.0";
      sourceRoot = "HTTPie.app";
      src = super.fetchurl {
        name = "HTTPie-${version}-arm64.dmg";
        url = "https://github.com/httpie/desktop/releases/download/v${version}/HTTPie-${version}-arm64.dmg";
        sha256 = "sha256-0ceSXjIga5SKX0+AHjLucqcLIiEw7IQJEQuGCyGTqgI=";
      };
      description = ''
        HTTPIE WEB & DESKTOP APP
      '';
      homepage = "https://httpie.io/product";
    };
}
