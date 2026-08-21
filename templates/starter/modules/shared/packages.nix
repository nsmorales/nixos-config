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

  # BEAM languages (Erlang/OTP 29 + Elixir from the same set, plus LSP)
  beam.packages.erlang_29.erlang
  beam.packages.erlang_29.elixir_1_20
  beam.packages.erlang_29.elixir-ls

  # Build tools for source compiles
  autoconf
  automake
  libtool
  m4
  pkg-config
  gcc
  gnumake
  openssl
  # hiPrio so buildEnv resolves the terminfo/g/ghostty collision with the ghostty package
  (pkgs.lib.hiPrio ncurses)

  # Python packages
  python3
  virtualenv
  uv
]
