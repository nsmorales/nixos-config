{ config, pkgs, lib, ... }:

let name = "%NAME%";
    user = "nmorales";
    email = "%EMAIL%"; in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;

    # oh-my-zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "kubectl"
        "tmux"
      ];
      # Theme is handled by powerlevel10k below
      theme = "";
    };

    # Additional plugins not in oh-my-zsh
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./config;
        file = "p10k.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];

    initContent = lib.mkBefore ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # PATH additions
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      # Editor
      export EDITOR="nvim"
      export VISUAL="nvim"

      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      # Always color ls and group directories
      alias ls='ls --color=auto'

      # Kubernetes aliases
      alias k="kubectl"
      alias kctx="kubectl ctx"
      alias kns="kubens"
      alias kdcj='kubectl describe cronjob'
      alias kdd='kubectl describe deployment'
      alias kdj='kubectl describe job'
      alias kdp='kubectl describe pod'
      alias kex='kubectl exec -ti'
      alias kgcj='kubectl get cronjob'
      alias kgd='kubectl get deployment'
      alias kge='kubectl get events --sort-by=.metadata.creationTimestamp'
      alias kgew='kubectl get events --watch'
      alias kgj='kubectl get job'
      alias kgp='kubectl get pod'
      alias kgs='kubectl get secret'
      alias klf='kubectl logs -f'
      alias klfa='kubectl logs -f --all-containers=true --since=10m'
      alias krr="kubectl rollout restart"

      kgpe() {
        kubectl get events --field-selector involvedObject.name="$1"
      }

      # K8s editor
      export KUBE_EDITOR=nvim
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs = {
      enable = true;
    };
    settings = {
      user.name = name;
      user.email = email;
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes vim-startify vim-tmux-navigator ];
    settings = { ignorecase = true; };
    extraConfig = ''
      "" General
      set number
      set history=1000
      set nocompatible
      set modelines=0
      set encoding=utf-8
      set scrolloff=3
      set showmode
      set showcmd
      set hidden
      set wildmenu
      set wildmode=list:longest
      set cursorline
      set ttyfast
      set nowrap
      set ruler
      set backspace=indent,eol,start
      set laststatus=2
      set clipboard=autoselect

      " Dir stuff
      set nobackup
      set nowritebackup
      set noswapfile
      set backupdir=~/.config/vim/backups
      set directory=~/.config/vim/swap

      " Relative line numbers for easy movement
      set relativenumber
      set rnu

      "" Whitespace rules
      set tabstop=8
      set shiftwidth=2
      set softtabstop=2
      set expandtab

      "" Searching
      set incsearch
      set gdefault

      "" Statusbar
      set nocompatible " Disable vi-compatibility
      set laststatus=2 " Always show the statusline
      let g:airline_theme='bubblegum'
      let g:airline_powerline_fonts = 1

      "" Local keys and such
      let mapleader=","
      let maplocalleader=" "

      "" Change cursor on mode
      :autocmd InsertEnter * set cul
      :autocmd InsertLeave * set nocul

      "" File-type highlighting and configuration
      syntax on
      filetype on
      filetype plugin on
      filetype indent on

      "" Paste from clipboard
      nnoremap <Leader>, "+gP

      "" Copy from clipboard
      xnoremap <Leader>. "+y

      "" Move cursor by display lines when wrapping
      nnoremap j gj
      nnoremap k gk

      "" Map leader-q to quit out of window
      nnoremap <leader>q :q<cr>

      "" Move around split
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      "" Easier to yank entire line
      nnoremap Y y$

      "" Move buffers
      nnoremap <tab> :bnext<cr>
      nnoremap <S-tab> :bprev<cr>

      "" Like a boss, sudo AFTER opening the file to write
      cmap w!! w !sudo tee % >/dev/null

      let g:startify_lists = [
        \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
        \ { 'type': 'sessions',  'header': ['   Sessions']       },
        \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      }
        \ ]

      let g:startify_bookmarks = [
        \ '~/Projects',
        \ '~/Documents',
        \ ]

      let g:airline_theme='bubblegum'
      let g:airline_powerline_fonts = 1
      '';
    };

  ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 11)
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
      ];
      window-decoration = false;
      cursor-style = "block";
      background-opacity = 0.95;
      background = "#1f2528";
      foreground = "#c0c5ce";

      # Padding
      window-padding-x = 16;
      window-padding-y = 16;

      # Auto-attach to tmux on launch.
      # If already inside tmux, just run zsh.
      # Otherwise: show sessions if any exist, prompt for name, attach or create.
      command = "${pkgs.zsh}/bin/zsh -c 'if [ -n \"$TMUX\" ]; then exec zsh; fi; tmux ls 2>/dev/null; read tmux_session; exec tmux new-session -A -s \${tmux_session:-default}'";
      # new-session -A attaches if the session exists, creates it if not — no separate attach needed

      # Colors — base16 Ocean
      palette = [
        "0=#1f2528"
        "1=#ec5f67"
        "2=#99c794"
        "3=#fac863"
        "4=#6699cc"
        "5=#c594c5"
        "6=#5fb3b3"
        "7=#c0c5ce"
        "8=#65737e"
        "9=#ec5f67"
        "10=#99c794"
        "11=#fac863"
        "12=#6699cc"
        "13=#c594c5"
        "14=#5fb3b3"
        "15=#d8dee9"
      ];
    };
  };

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    matchBlocks = {
      "*" = {
        sendEnv = [ "LANG" "LC_*" ];
        hashKnownHosts = true;
      };
      # Example SSH configuration for GitHub
      # "github.com" = {
      #   identitiesOnly = true;
      #   identityFile = [
      #     (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
      #       "/home/${user}/.ssh/id_github"
      #     )
      #     (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      #       "/Users/${user}/.ssh/id_github"
      #     )
      #   ];
      # };
    };
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
      dracula
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5'
        '';
      }
    ];
    terminal = "tmux-256color";
    prefix = "C-Space";
    escapeTime = 10;
    historyLimit = 50000;
    extraConfig = ''
      # True color support — pass 24-bit RGB through to the outer terminal
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -sa terminal-overrides ",ghostty:Tc"
      set-option -sa terminal-overrides ",tmux-256color:Tc"

      # Focus events for terminals that support them
      set -g focus-events on

      # Mouse support
      set -g mouse on

      # Disable auto window renaming
      set-option -g allow-rename off

      # Display time for messages
      set -g display-time 4000

      # Dracula theme config
      set -g @dracula-plugins "git kubernetes-context cpu-usage ram-usage network-vpn battery time"
      set -g @dracula-kubernetes-context-label "k8s: "
      set -g @dracula-kubernetes-eks-hide-arn true
      set -g @dracula-kubernetes-hide-user true

      # -----------------------------------------------------------------------------
      # Splits — keep current path
      # -----------------------------------------------------------------------------
      unbind '"'
      unbind %
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Vim-style pane navigation (with prefix)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Alt-arrow to switch panes without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Smart pane switching with vim awareness (vim-tmux-navigator)
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      # -----------------------------------------------------------------------------
      # Vi copy mode
      # -----------------------------------------------------------------------------
      set-window-option -g mode-keys vi
      bind-key v copy-mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x

      # -----------------------------------------------------------------------------
      # Floating windows
      # -----------------------------------------------------------------------------
      # Lazygit popup (prefix + g)
      bind-key g display-popup -E -d "#{pane_current_path}" -xC -yC -w 80% -h 75% "lazygit"

      unbind Space
    '';
  };
}
