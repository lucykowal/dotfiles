#!/bin/bash

# fuzzy find tmux panes by their text content

set -euo pipefail

# temporary file to store pane data
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# get all sessions, windows, and panes
tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{window_name} #{pane_title}" | while read -r pane_info; do
    pane_id=$(echo "$pane_info" | cut -d' ' -f1)
    window_name=$(echo "$pane_info" | cut -d' ' -f2- | cut -d' ' -f1)

    # capture pane content (visible area only, use -p for full history)
    content=$(tmux capture-pane -t "$pane_id" -p 2>/dev/null || echo "")

    # skip empty panes
    if [[ -n "$content" ]]; then
        # format: pane_id|window_info|content_preview
        echo "$content" | while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                echo "$pane_id|$window_name|$line" >> "$temp_file"
            fi
        done
    fi
done

# check if we found any panes with content
if [[ ! -s "$temp_file" ]]; then
    exit 1
fi

# use fzf to select a pane
selected=$(cat "$temp_file" | fzf \
    --delimiter='|' \
    --with-nth=2,3 \
    --preview='tmux capture-pane -t {1} -p' \
    --preview-window='right:60%:wrap' \
    --ansi \
    --no-sort || true)

# extract the pane ID and open
if [[ -n "$selected" ]]; then
    pane_id=$(echo "$selected" | cut -d'|' -f1)
    tmux switch-client -t "$pane_id"
else
    exit 1
fi
