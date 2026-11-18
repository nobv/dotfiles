# Prebuilt upstream binaries, for when nixpkgs-unstable lags behind a security
# release. Nothing uses it right now; add an entry here and point the module at
# it when that happens again.
self: super:
let
  mkPrebuiltBin =
    {
      pname,
      version,
      url,
      hash,
      installPhase,
      description,
      homepage,
      license,
      mainProgram,
    }:
    super.stdenvNoCC.mkDerivation {
      inherit pname version installPhase;
      src = super.fetchurl { inherit url hash; };

      # Stripping or patching would invalidate the arm64 code signature.
      dontBuild = true;
      dontFixup = true;

      meta = {
        inherit
          description
          homepage
          license
          mainProgram
          ;
        maintainers = with super.lib.maintainers; [ nobv ];
        platforms = [ "aarch64-darwin" ];
      };
    };
in
{ }
