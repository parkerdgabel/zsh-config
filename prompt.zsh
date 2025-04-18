# — enable dynamic prompt evaluation
autoload -Uz vcs_info
setopt PROMPT_SUBST

# — function to gather per‑prompt info
precmd() {
  # SSH?
  if [[ -n $SSH_TTY || -n $SSH_CONNECTION ]]; then
    SSH_ICON="🔒"
  else
    SSH_ICON=""
  fi

  # Container?
  if [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    CONTAINER_ICON="📦"
  else
    CONTAINER_ICON=""
  fi

  # Git branch info
  vcs_info
}
zstyle ':vcs_info:git:*' formats '%b '
# style your prompt; adjust colors or icons as you like
PROMPT='%F{green}%*%f ${SSH_ICON}${CONTAINER_ICON} %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f
> '
