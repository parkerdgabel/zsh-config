# ===============================================================
#                           Set up zsh
#  ===============================================================

# Check if the operating system is macOS
if [[ "$(uname)" == "Darwin" ]]; then
  # Verify that Homebrew is installed
  if type brew &>/dev/null; then
    # Update FPATH to include Homebrew's zsh completions
    FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"

    # Initialize zsh completion system
    autoload -Uz compinit
    compinit
  fi
fi

if [ -f "$HOME/.fzf.zsh" ]; then
    source "$HOME/.fzf.zsh"
fi


autoload -Uz compinit
compinit

