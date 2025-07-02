{
  description = "Audio device switcher using Babashka and wpctl";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      audio-switcher = pkgs.writeShellScriptBin "audio-switcher" ''
        #!/usr/bin/env bb
        
        ${builtins.readFile ./audio-switcher.clj}
      '';
      
    in {
      # Make the script available as a package
      packages.${system} = {
        default = audio-switcher;
        audio-switcher = audio-switcher;
      };
              
      # Development shell (minimal since deps are system-wide)
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ ];
      };
      
      # NixOS module for easy integration
      nixosModules.default = { config, lib, pkgs, ... }: {
        options.programs.audio-switcher = {
          enable = lib.mkEnableOption "audio switcher script";
        };
        
        config = lib.mkIf config.programs.audio-switcher.enable {
          environment.systemPackages = [ 
            self.packages.${system}.audio-switcher 
          ];
        };
      };
      
      # App entry for desktop integration
      apps.${system}.default = {
        type = "app";
        program = "${audio-switcher}/bin/audio-switcher";
        meta = {
          description = "Toggle between built-in audio and SteelSeries headset";
          platforms = [ "x86_64-linux" ];
        };
      };
    };
}
