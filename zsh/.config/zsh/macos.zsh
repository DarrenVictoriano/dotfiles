function history-fzf() {
  local selected
  selected=$(history | awk '{ $1=""; print substr($0,2) }' | fzf --height 40% --reverse --border --ansi) || return
  if [[ -n $selected ]]; then
    # Use `readline` to insert the text into the prompt in bash
    # For zsh, you might need a different approach
    printf '%s' "$selected" | pbcopy   # copy to clipboard
    echo "Copied to clipboard: $selected"
  fi
}


function trash() {
    # Try to move the item to Trash
    mv -f "$1" ~/.Trash
    if [ $? -eq 0 ]; then
        echo "Moved to Trash: '$1'"
    else
        # If moving to Trash fails, delete the item
        rm -rf "$1"
        if [ $? -eq 0 ]; then
            echo "Deleted: '$1'"
        else
            echo "Failed to delete: '$1'"
        fi
    fi
}

function pandoc-md-to-pdf() {
    # https://github.com/Wandmalfarbe/pandoc-latex-template?tab=readme-ov-file
    pandoc "$1" -o "$2" --verbose --template=eisvogel --from markdown --listings -V listings-no-page-break -V listings-disable-line-numbers
}

