
if ! [[ -e ~/.zshrc_beals_set ]]; then

   #Install packages if they do not exit
   packages=("neovim" "fzf" "zoxide" "bat" "tar" "yazi" "fastfetch" "eza")

   homebrewpath=false

   if [[ $(uname) == "Darwin" ]] && ! command -v brew &>/dev/null;  then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

   elif ! command -v brew &>/dev/null; then 
      git clone https://github.com/Homebrew/brew
      mv brew .homebrew
      export PATH=${HOME}/.homebrew/bin:${PATH}
      homebrewpath=true
   fi


   is_installed_with_brew() {
      command -v brew &>/dev/null && brew list "$1" &>/dev/null
   }

   # Function to install a package using Homebrew
   install_with_brew() {
   if command -v brew &>/dev/null; then
      if ! is_installed_with_brew "$1"; then
         echo "Attempting to install $1 using Homebrew..."
         brew install "$1"
      fi
   fi
   }

   # Function to check if a package exists in DNF or APT before attempting install
   package_exists_in_dnf() {
   dnf list --available "$1" &>/dev/null
   }

   package_exists_in_apt() {
   apt-cache show "$1" &>/dev/null
   }

   # Check system package manager and Homebrew before installation
   if command -v dnf &>/dev/null; then
   for package in "${packages[@]}"; do
      if ! rpm -q "$package" &>/dev/null && ! is_installed_with_brew "$package"; then
         if package_exists_in_dnf "$package"; then
         echo "Installing $package with DNF..."
         sudo dnf install "$package" -y || install_with_brew "$package"
         else
         echo "Package $package not found in DNF. Falling back to Homebrew..."
         install_with_brew "$package"
         fi
      fi
   done

   elif command -v apt &>/dev/null; then
   for package in "${packages[@]}"; do
      if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed" && ! is_installed_with_brew "$package"; then
         if package_exists_in_apt "$package"; then
         echo "Installing $package with APT..."
         sudo apt install "$package" -y || install_with_brew "$package"
         else
         echo "Package $package not found in APT. Falling back to Homebrew..."
         install_with_brew "$package"
         fi
      fi
   done
   else
   echo "Neither DNF nor APT found. Attempting installation using Homebrew..."
   for package in "${packages[@]}"; do
      if ! is_installed_with_brew "$package"; then
         install_with_brew "$package"
      fi
   done
   fi

   if ! [ -f ".get_distro" ]; then
      curl https://raw.githubusercontent.com/bealsbe/dotfiles/refs/heads/master/.get_distro -o .get_distro
      chmod +x .get_distro
   fi
   
   ##stupid but works 
   touch .zshrc_beals_set
fi 
    
#set kitty display and run fastfetch
if [ "$TERM" = "xterm-kitty" ]; then 
   export TERM=xterm-256color
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

current_distro=$(sh .get_distro 2>/dev/null)
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
