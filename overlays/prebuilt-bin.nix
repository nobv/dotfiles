# Prebuilt upstream binaries, for when nixpkgs-unstable lags behind a security
# release (2026-10: Node.js 24.22.1, Go 1.26.10 and uv 0.13.4 are not yet in
# nixpkgs-unstable).
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
{
  nodejs-bin = mkPrebuiltBin rec {
    pname = "nodejs-bin";
    version = "24.22.1";
    url = "https://nodejs.org/dist/v${version}/node-v${version}-darwin-arm64.tar.gz";
    hash = "sha256-icaCWT12zUQjP6U7FWMmTn3py7GJytFpE1xbT637wKc=";
    installPhase = ''
      mkdir -p $out
      cp -R bin include lib share $out/
    '';
    description = "Node.js (prebuilt binary from nodejs.org)";
    homepage = "https://nodejs.org";
    license = super.lib.licenses.mit;
    mainProgram = "node";
  };

  go-bin = mkPrebuiltBin rec {
    pname = "go-bin";
    version = "1.26.10";
    url = "https://go.dev/dl/go${version}.darwin-arm64.tar.gz";
    hash = "sha256-C1GDSSKSraFw+bVhqDSGOAjdAu26WZ5K0OiYmTMAILM=";
    # go derives GOROOT from its resolved executable path, so symlinks into
    # share/go work.
    installPhase = ''
      mkdir -p $out/share/go $out/bin
      cp -R . $out/share/go/
      ln -s $out/share/go/bin/go $out/share/go/bin/gofmt $out/bin/
    '';
    description = "Go (prebuilt binary from go.dev)";
    homepage = "https://go.dev";
    license = super.lib.licenses.bsd3;
    mainProgram = "go";
  };

  uv-bin = mkPrebuiltBin rec {
    pname = "uv-bin";
    version = "0.13.4";
    url = "https://github.com/astral-sh/uv/releases/download/${version}/uv-aarch64-apple-darwin.tar.gz";
    hash = "sha256-4LHUdDzmTFXZ8PSkRK+muBElaABw7gToU/zQ9sHr+PE=";
    installPhase = ''
      mkdir -p $out/bin
      cp uv uvx $out/bin/
    '';
    description = "uv (prebuilt binary from GitHub Releases)";
    homepage = "https://github.com/astral-sh/uv";
    license = with super.lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "uv";
  };
}
