
fzf_select() {
  # Use find to list files (skipping hidden ones)
  local selected
  selected=$(find . -type f -not -path '*/\.*' 2>/dev/null | fzf --preview 'bat --style=numbers --color=always {}' --preview-window=right:60%) || return
  if [[ -d "$selected" ]]; then
    cd "$selected"
  else
    ${EDITOR:-vim} "$selected"
  fi
}
# Create a ZLE widget and bind it to Ctrl-F (change binding as desired)
fzf_select_widget() {
  zle -I
  fzf_select
  zle reset-prompt
}
zle -N fzf_select_widget
bindkey '^F' fzf_select_widget

fzf_kill() {
  local pid
  # For macOS, use 'ps -ax' instead of 'ps -ef'
  pid=$(ps -ax | sed 1d | fzf --header="Select a process to kill" --reverse | awk '{print $1}')
  if [[ -n "$pid" ]]; then
    kill -9 "$pid" && echo "Killed process $pid"
  fi
}
fzf_kill_widget() {
  zle -I
  fzf_kill
  zle reset-prompt
}
zle -N fzf_kill_widget
bindkey '^K' fzf_kill_widget

fzf_git_checkout() {
  # List both local and remote branches, excluding HEAD references.
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/^[* ]*//' | fzf --preview 'git log --oneline --color=always {}' --preview-window=right:60%) || return
  git checkout "$(echo "$branch" | sed 's#remotes/##')" 2>/dev/null
}
fzf_git_checkout_widget() {
  zle -I
  fzf_git_checkout
  zle reset-prompt
}
zle -N fzf_git_checkout_widget
bindkey '^B' fzf_git_checkout_widget

fzf_git_add() {
  local files selected file_list=()
  files=$(git status -s | fzf --multi --header="Select files to add" --preview 'git diff --color=always {1}' --preview-window=right:60%) || return
  while IFS= read -r line; do
    # Strip the git status prefix to leave just the filename.
    file_list+=("$(echo "$line" | sed 's/^[?MADRC!]* *//')")
  done <<< "$files"
  if (( ${#file_list[@]} )); then
    git add "${file_list[@]}"
  fi
}
fzf_git_add_widget() {
  zle -I
  fzf_git_add
  zle reset-prompt
}

fzf_ssh() {
  local host
  host=$(awk '/^Host / {print $2}' ~/.ssh/config | fzf --prompt="SSH Host> ") || return
  ssh "$host"
}
fzf_ssh_widget() {
  zle -I
  fzf_ssh
  zle reset-prompt
}

fzf_docker_attach() {
  local container container_id
  container=$(docker ps --format "{{.ID}}: {{.Names}}" | fzf --header="Select Docker Container> ") || return
  container_id=$(echo "$container" | awk -F ':' '{print $1}')
  docker attach "$container_id"
}

fzf_docker_attach_widget() {
  zle -I
  fzf_docker_attach
  zle reset-prompt
}

fzf_man() {
  local manpage
  manpage=$(apropos . | fzf --prompt="Man Page> " | awk -F " - " '{print $1}') || return
  man "$manpage"
}

fzf_man_widget() {
  zle -I
  fzf_man
  zle reset-prompt
}

edit_current_command() {
  # Create a temporary file
  local tmpfile
  tmpfile=$(mktemp /tmp/.zsh_command_edit.XXXXXX)
  # Write the current command (stored in $BUFFER) to the file
  print -r -- "$BUFFER" > "$tmpfile"
  # Open the file in the editor specified by $EDITOR (or vim if not set)
  ${EDITOR:-vim} "$tmpfile"
  # Read the edited command back into the command line buffer
  BUFFER=$(<"$tmpfile")
  # Remove the temporary file
  rm -f "$tmpfile"
  # Refresh the prompt
  zle reset-prompt
}


zle -N fzf_git_add_widget
bindkey '^G' fzf_git_add_widget  # Ctrl-G: fzf Git Add

zle -N fzf_ssh_widget
bindkey '^S' fzf_ssh_widget

zle -N fzf_docker_attach_widget
bindkey '^D' fzf_docker_attach_widget  # Ctrl-D: fzf Docker Attach

zle -N edit_current_command
bindkey '^X^E' edit_current_command
