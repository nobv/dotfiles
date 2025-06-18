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
      
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Shared module auto-discovery function
      lib = pkgs.lib;
      modulesPath = ./modules;
      
      # Get all modules that have default.nix (both directories and single files)
      getModules = dir:
        let
          contents = builtins.readDir (modulesPath + "/${dir}");
        in
        lib.mapAttrsToList (name: type:
          if type == "directory" then
            modulesPath + "/${dir}/${name}"
          else
            modulesPath + "/${dir}/${name}"
        ) (lib.filterAttrs (name: type: 
          (type == "directory" && builtins.pathExists (modulesPath + "/${dir}/${name}/default.nix")) ||
          (type == "regular" && name == "default.nix")
        ) contents);

      # Auto-discover all modules
      allModules = lib.flatten [
        (getModules "ai")
        (getModules "browsers")
        (getModules "checkers")
        (getModules "communication")
        (getModules "design")
        (getModules "development")
        (getModules "editors")
        (getModules "languages")
        (getModules "media")
        (getModules "productivity")
        (getModules "security")
        (getModules "system")
        (getModules "terminal")
        (getModules "utilities")
      ];
      
      # Function to create a Darwin system with machine-specific config  
      mkDarwinSystem = { machine }:
        let
          machineConfigPath = ./machines/${machine}/config.nix;
          machineConfig = 
            if builtins.pathExists machineConfigPath
            then import machineConfigPath
            else throw "Missing required config file: machines/${machine}/config.nix";
          username = 
            if machineConfig.username == "REPLACE_WITH_YOUR_USERNAME"
            then throw "Please update machines/${machine}/config.nix with your actual username (currently set to placeholder 'REPLACE_WITH_YOUR_USERNAME')"
            else machineConfig.username;
        in
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            home-manager.darwinModules.home-manager
            ./machines/${machine}
          ] ++ allModules;
          
          specialArgs = {
            inherit inputs nixpkgs nixpkgs-stable machine username;
          };
        };
    in
    {
      darwinConfigurations = {
        # Machine-specific configurations
        macbook = mkDarwinSystem { machine = "macbook"; };
        macmini = mkDarwinSystem { machine = "macmini"; };
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
