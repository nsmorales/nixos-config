{ pkgs }:

with pkgs; [
  # General packages for development and system management
  bash-completion
  bat
  btop
  coreutils
  killall
  openssh
  sqlite
  wget
  zip
  unzip

  # Encryption and security tools
  age
  gnupg

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Fonts are defined in modules/shared/fonts.nix (single source)

  # Text and terminal utilities
  ghostty
  alacritty # Backup terminal emulator
  htop
  jq
  neovim
  ripgrep
  tree
  tmux

  # Wayland / clipboard
  wl-clipboard

  # Development tools
  curl
  fd
  fzf
  gh
  lazygit
  direnv
  mise
  opencode

  # Shell
  zsh-powerlevel10k
  zsh-syntax-highlighting
  zsh-autosuggestions

  # Cloud / DevOps
  terraform
  kubectl
  awscli2

  # Programming languages and runtimes
  go
  rustc
  cargo
  openjdk

  # Python packages
  python3
  virtualenv
  uv
]
