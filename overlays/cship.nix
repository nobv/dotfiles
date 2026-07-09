self: super: {

  cship = super.rustPlatform.buildRustPackage rec {
    pname = "cship";
    version = "1.8.0";

    src = super.fetchFromGitHub {
      owner = "stephenleo";
      repo = "cship";
      rev = "v${version}";
      hash = "sha256-bZaXHsShsd4M+vxz5ZfwXqy+awHuYp6zZczx+46OR0Y=";
    };

    cargoHash = "sha256-B/fRtRbfyIxlsBU7eTOWG+VI8+nPN0Y0Y2oJRaeOOGg=";

    meta = with super.lib; {
      description = "Customizable statusline for Claude Code with Starship-style TOML config";
      homepage = "https://cship.dev";
      license = licenses.asl20;
      maintainers = with maintainers; [ nobv ];
      platforms = platforms.unix;
      mainProgram = "cship";
    };
  };
}
