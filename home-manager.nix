{ config, pkgs, ... }:

{
  # Enable Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      prompt_order = ["directory" "git_branch" "git_status" "nodejs" "rust" "python" "time" "character"];
      character.symbol = "❯";
      directory.truncate_to_repo = false;
    };
  };

  # Fuzzy finder
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # CLI tools
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
    fira-code-nerdfont
  ];

  # Git with delta for diffs
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

  # Set Zsh as default shell
  home.shell = pkgs.zsh;
}

