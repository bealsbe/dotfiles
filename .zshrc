
#Install packages if they do not exit
packages=("neovim" "fzf" "zoxide" "bat" "tar")

homebrewpath=false

if [[ $(uname) == "Darwin" ]] && ! command -v brew &>/dev/null;  then
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

elif ! command -v brew &>/dev/null; then 
   git clone https://github.com/Homebrew/brew
   mv brew .homebrew
   export PATH=${HOME}/.homebrew/bin:${PATH}
   homebrewpath=true
fi

if ! command -v yazi &>/dev/null; then
   brew install yazi
fi


if ! command -v fastfetch &>/dev/null; then
   brew install fastfetch
fi


if ! command -v eza &>/dev/null; then
   brew install eza
fi



if command -v dnf &>/dev/null; then
  for package in "${packages[@]}"; do
    if ! rpm -q "$package" &>/dev/null; then
      echo "Package $package is missing. Installing..."
      sudo dnf install "$package" -y
    fi
  done

elif command -v apt &>/dev/null; then
  for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "$package"; then
      echo "Package $package is missing. Installing..."
      sudo apt install "$package" -y
    fi
  done
fi

if ! [ -f ".get_distro" ]; then
   curl https://raw.githubusercontent.com/bealsbe/dotfiles/refs/heads/master/.get_distro -o .get_distro
   chmod +x .get_distro
fi


current_distro=$(sh .get_distro 2>/dev/null)
#set kitty display and run fastfetch
if [ "$TERM" = "xterm-kitty" ]; then 
   export TERM=xterm-256color
fi

if [[ $current_distro =~ "Fedora" ]]; then
      fastfetch --logo ~/.config/icons/beals_logo.png --logo-width 28
else 
   fastfetch
fi


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
if [[ $DISPLAY ]] || [[ $TERM == 'xterm-256color' ]]; then
  zinit ice depth=1; zinit light romkatv/powerlevel10k
fi

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza --icons --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons --color $realpath'
unsetopt nomatch

export PATH="<path>:$PATH"
export EDITOR=nvim

if [[ $(uname) == "Linux" ]] && [[ $current_distro =~ "Fedora" ]]; then
   alias update='sudo dnf upgrade --refresh -y; sudo pkcon update; fwupdmgr update; flatpak update -y; brew update; brew upgrade;'
   alias startp='startplasma-wayland'
   alias logoutp='loginctl terminate-user beals'
   alias bios='systemctl reboot --firmware-setup'
   alias tclock='tty-clock -c -C 5 -r -n -r -f "%A, %B %d %Y"'
   alias neofetch='fastfetch --logo ~/.config/icons/beals_logo.png' 

fi

alias cat='bat'
alias ls='eza --color --icons'
alias tree="tree -L 3 -a -I '.git"
alias vim='nvim'
alias c='clear'
alias y='local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"'

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ $(uname) == "Linux" ]] && [[ $homebrew == false ]]; then
   export PATH=${HOME}/homebrew/bin:${PATH}
fi
