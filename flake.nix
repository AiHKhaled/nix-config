{
  description = "NixOS configuration with Home Manager and dev terminal setup";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    #catppuccin.url = "github:catppuccin/nix/release-25.05";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    vscode-server,
    # catppuccin,
    ...
  } @ inputs: let
    runOrRaise = app: ''
      ${pkgs.xdotool}/bin/xdotool search --onlyvisible --classname ${app} windowactivate 2>/dev/null \
      || ${pkgs.dbus}/bin/dbus-send --session --dest=org.gnome.Shell \
         /org/gnome/Shell org.gnome.Shell.Eval string:'Meta.launch_app_by_id("${app}.desktop", 0, -1)'
    '';
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        ./modules/dynamic-wallpaper.nix
        home-manager.nixosModules.home-manager
        vscode-server.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.elijah = {pkgs, ...}: {
            home.stateVersion = "25.05";
            dconf.settings = {
              "org/gnome/settings-daemon/plugins/media-keys" = {
                custom-keybindings = [
                  "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                  "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
                ];
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
                name = "Ghostty";
                command = "ghostty";
                binding = "<Super>g";
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
                name = "Brave";
                command = "brave";
                binding = "<Super>b";
              };
            };

            programs.zsh = {
              enable = true;
              enableCompletion = true;
              syntaxHighlighting.enable = true;
              autosuggestion.enable = true;
              history.size = 10000;
              initContent = ''
                if [ -f ~/.git_aliases ]; then
                   source ~/.git_aliases
                fi
              '';
            };
            programs.starship = {
              enable = true;
              settings = {
                add_newline = false;
                format = "$directory$git_branch$git_status$nodejs$deno$bun$rust$python$time$character";
                character = {
                  success_symbol = "[➜](bold green) ";
                  error_symbol = "[➜](bold red) ";
                };
                directory.truncate_to_repo = false;
              };
            };
            programs.fzf = {
              enable = true;
              defaultOptions = [
                "--height 40%"
                "--layout=reverse"
                "--border"
              ];
            };
            programs.git = {
              enable = true;
              extraConfig = {
                core.pager = "delta";
                interactive.diffFilter = "delta --color-only";
                delta = {
                  features = "side-by-side line-numbers decorations";
                  whitespace-error-style = "22 reverse";
                };
              };
            };
            programs.vscode = {
              enable = true;
              package = pkgs.vscode-fhs;
              profiles.default.userSettings = nixpkgs.lib.recursiveUpdate (builtins.fromJSON (builtins.readFile ./vscode/styles.json)) {
                update.mode = "none";
                extensions.autoUpdate = true;
              };
            };

            home.packages = with pkgs; [
              ghostty
              bat
              eza
              fd
              ripgrep
              tldr
              procs
              glow
              httpie
              btop
              delta
              lsd
              alejandra
              nixd
              pnpm
              vlc
              timg
              ffmpeg
              brave
              yt-dlp
              aria2
              ani-skip
              mpv
            ];
          };
        }
        {
          users.users.elijah.shell = nixpkgs.legacyPackages.${system}.zsh;

          virtualisation.docker.enable = true;
          users.users.elijah.extraGroups = ["docker"];

          services.openssh.settings = {
            enable = true;
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };

          fonts.packages = with nixpkgs.legacyPackages.${system}; [
            nerd-fonts.agave
          ];
        }
      ];
    };
  };
}
