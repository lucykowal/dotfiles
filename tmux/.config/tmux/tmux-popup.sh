#!/bin/bash
# credit to Will Richardson
# https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/

session="_popup_$(tmux display -p '#S')"

if ! tmux has -t "$session" 2> /dev/null; then
	session_id="$(tmux new-session -dP -s "$session" -F '${session_id}')"
	tmux set-option -s -t "$session_id" key-table popup
	tmux set-option -s -t "$session_id" status off
	tmux set-option -s -t "$session_id" prefix None
	session="$session_id"
fi

exec tmux attach -t "$session" > /dev/null
