{ pkgs, username, secrets, ... }: {
  home.stateVersion = "24.11";

  home.username = username;  # Теперь "ser"
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  home.packages = with pkgs; [
    bat
    neovim
    tmux
    git
    fzf
    htop
    zoxide
    fd
    eza
    du-dust
    ripgrep
    jq
    wget
    yq-go
    tree
    zsh-syntax-highlighting
    inetutils
    zsh
    vim
  ];

  programs = {
    zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -lah";
        gs = "git status";
      };
    };
    git = {
      enable = true;
      userName = secrets.git.userName;
      userEmail = secrets.git.userEmail;
    };
  };
}
