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
      version = "2.4.1";
      sourceRoot = "Morgen.app";
      src = super.fetchurl {
        url = "https://dl.todesktop.com/210203cqcj00tw1/mac/dmg/arm64";
        sha256 = "1kybsh54042vpkhf7sx26d71gzf4dq2km6xq0605xbjbpr160r9a";
      };
      description = ''
        Make the most out of your time
      '';
      homepage = "https://morgen.so";
    };

}
