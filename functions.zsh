async_notify() {
  "$@" &
  local cmd_pid=$!
  (
    wait $cmd_pid
    local exit_code=$?
    if command -v terminal-notifier >/dev/null 2>&1; then
      if [[ $exit_code -eq 0 ]]; then
        terminal-notifier -title "Command Succeeded" -message "'$*' finished"
      else
        terminal-notifier -title "Command Failed" -message "'$*' failed"
      fi
    else
      echo "Command '$*' finished with exit code $exit_code"
    fi
  ) &
  echo "Command is running in the background with PID $cmd_pid"
}
backup() {
  if [ $# -ne 1 ]; then
    echo "Usage: backup filename"
    return 1
  fi
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "backup: $file not found."
    return 1
  fi
  local backup_file="${file}.$(date +%Y%m%d%H%M%S).bak"
  cp "$file" "$backup_file" && echo "Backup created: $backup_file"
}

colortree() {
  if command -v tree >/dev/null 2>&1; then
    tree "$@"
  else
    find . -print | sed -e 's;[^/]*\/; |____;g;s;____ |; |;g'
  fi
}

openurl() {
  if [ -z "$1" ]; then
    echo "Usage: openurl <url>"
    return 1
  fi
  if command -v open >/dev/null 2>&1; then
    open "$1"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$1"
  else
    echo "No browser opener found."
  fi
}

copy_path() {
  if command -v pbcopy >/dev/null 2>&1; then
    pwd | pbcopy && echo "Copied $(pwd) to clipboard."
  elif command -v xclip >/dev/null 2>&1; then
    pwd | xclip -sel clip && echo "Copied $(pwd) to clipboard."
  else
    echo "No clipboard utility available."
  fi
}

prompt_git_info() {
  # Try to get the current branch (if not in a git repo, return nothing)
  local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return

  # Check for dirty status: if there’s output from 'git status --porcelain', mark as dirty.
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    # Red dirty symbol
    local dirty_flag="%F{red}✗%f"
  else
    # Green clean symbol
    local dirty_flag="%F{green}✓%f"
  fi

  # Return formatted git status; adjust spacing or symbols as desired.
  echo "[$branch $dirty_flag]"
}

pck() {
  # Usage: pck <directory> [format] [output_archive_name]
  # Supported formats: tar.gz (default), tar.bz2, tar.xz, zip

  if [ "$#" -lt 1 ]; then
    echo "Usage: pck <directory> [format] [output_archive_name]"
    return 1
  fi

  local dir="$1"
  if [ ! -d "$dir" ]; then
    echo "Error: '$dir' is not a valid directory."
    return 1
  fi

  # Get the archive format (default is tar.gz)
  local format="${2:-tar.gz}"
  # If an output name is provided, use it; otherwise, derive one from the directory name.
  local output="${3:-${dir%/}.${format}}"

  case "$format" in
    tar.gz)
      tar -czf "$output" "$dir" || { echo "Compression failed."; return 1; }
      echo "Directory '$dir' compressed to '$output'."
      ;;
    tar.bz2)
      tar -cjf "$output" "$dir" || { echo "Compression failed."; return 1; }
      echo "Directory '$dir' compressed to '$output'."
      ;;
    tar.xz)
      tar -cJf "$output" "$dir" || { echo "Compression failed."; return 1; }
      echo "Directory '$dir' compressed to '$output'."
      ;;
    zip)
      # Ensure zip is available; many systems have it by default.
      if ! command -v zip >/dev/null 2>&1; then
        echo "Error: zip is not installed."
        return 1
      fi
      zip -r "$output" "$dir" || { echo "Compression failed."; return 1; }
      echo "Directory '$dir' compressed to '$output'."
      ;;
    *)
      echo "Unsupported format: $format"
      echo "Supported formats: tar.gz, tar.bz2, tar.xz, zip"
      return 1
      ;;
  esac
}
