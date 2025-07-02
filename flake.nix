{
  description = "Audio device switcher using Babashka and wpctl";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        audio-switcher = pkgs.writeShellScriptBin "audio-switcher" ''
          export PATH=${pkgs.lib.makeBinPath [ 
            pkgs.babashka 
            pkgs.wireplumber  # provides wpctl
          ]}:$PATH
          
          cat << 'EOF' | ${pkgs.babashka}/bin/bb "$@"
          ${builtins.readFile ./audio-switcher.clj}
          EOF
        '';
        
      in {
        # Make the script available as a package
        packages.default = audio-switcher;
        packages.audio-switcher = audio-switcher;
        
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            babashka
            wireplumber
          ];
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
        apps.default = {
          type = "app";
          program = "${audio-switcher}/bin/audio-switcher";
        };
      });
}
