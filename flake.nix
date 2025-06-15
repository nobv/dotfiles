{
  description = "nobv's Nix Darwin configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, darwin, home-manager }:
    let
      system = "aarch64-darwin";
      username = "nobv";
      
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Shared module auto-discovery function
      lib = pkgs.lib;
      modulesPath = ./modules;
      
      # Get all module directories that have default.nix
      getModules = dir:
        let
          contents = builtins.readDir (modulesPath + "/${dir}");
        in
        lib.mapAttrsToList (name: type:
          modulesPath + "/${dir}/${name}"
        ) (lib.filterAttrs (name: type: 
          type == "directory" && builtins.pathExists (modulesPath + "/${dir}/${name}/default.nix")
        ) contents);

      # Auto-discover all modules
      allModules = lib.flatten [
        (getModules "app")
        (getModules "checkers") 
        (getModules "editor")
        (getModules "font")
        (getModules "lang")
        (getModules "term")
        (getModules "tools")
      ];
      
      # Function to create a Darwin system with machine-specific config
      mkDarwinSystem = { machine }: darwin.lib.darwinSystem {
        inherit system;
        modules = [
          home-manager.darwinModules.home-manager
          ./machines/${machine}
        ] ++ allModules;
        
        specialArgs = {
          inherit inputs nixpkgs nixpkgs-stable username machine;
        };
      };
    in
    {
      darwinConfigurations = {
        # Machine-specific configurations
        macbook = mkDarwinSystem { machine = "macbook"; };
        macmini = mkDarwinSystem { machine = "macmini"; };
        test = mkDarwinSystem { machine = "test"; };
        work = mkDarwinSystem { machine = "work"; };
      };
      
      # Development shell for working with the configuration
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          nix-tree
        ];
      };
    };
}
