{ lib, ... }:

{
  format = ''
    [┌──────────────────────────────────────────────────────>](bold green)
    [│](bold green)[on ☁ Ⓐ ](bold bright-yellow)$aws
    [│](bold green)[on ☁ Ⓖ ](bold bright-blue)$gcloud
    [│](bold green)[on   ⎈ ](bold red)$kubernetes
    $all
    [│](bold green)$character '';

  aws = {
    format = "[$symbol($profile )(\\($region\\) )]($style)";
    symbol = "";
    region_aliases = {
      ap-northeast-1 = "🗼";
      ap-southeast-2 = "au";
      us-east-1 = "va";
    };
  };

  battery = {
    disabled = true;
  };

  character = {
    error_symbol = "[✗](bold red) ";
    success_symbol = "[➜](bold green) ";
  };

  directory = {
    truncation_length = 1;
    truncation_symbol = "…/";
  };

  gcloud = {
    format = "[$symbol$account(@$domain)(\\($project\\))(\\($region\\) )]($style) ";
    symbol = "";
    region_aliases = {
      asia-northeast1 = "🗼";
    };
  };

  kubernetes = {
    disabled = false;
    format = "[$context \\($namespace\\)]($style) ";
    style = "bold red";
    context_aliases = {
      "gke_.*_(?P<cluster>[\\\\w-]+)" = "gke-$cluster";
    };
  };

  line_break = {
    disabled = true;
  };

  purescript = {
    "symbol" = "<≡> ";
  };
}
