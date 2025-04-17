
# ===============================
# Enable vi Mode for Zsh
# ===============================
# This command switches your editing mode to vi (like in vim).
bindkey -v
# --- Rebind keys in vi insert mode ---
bindkey -M viins '^P' up-line-or-history  # Ctrl-P recalls previous command
bindkey -M viins '^E' end-of-line           # Ctrl-E moves the cursor to end-of-line

# --- Optional: Also set key bindings for vi command mode if desired ---
bindkey -M vicmd '^P' up-line-or-history
bindkey -M vicmd '^E' end-of-line

bindkey -r '^N'
bindkey '^N' down-line-or-history

