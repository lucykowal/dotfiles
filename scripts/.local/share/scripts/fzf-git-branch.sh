#!/bin/bash

# tmux capture-pane -CJp -S -400 |\
#   rg -oe '\$[^\d {(\[][A-Za-z_\d]*' |\
#   awk '!seen[$0]++' |\
#   tac |\
#   fzf --tmux 60%,border-native -m -1 -0 |\
#   xargs tmux send-keys -l

git -C $1 status $? &>/dev/null || exit 1
branch=$(git -C $1 branch --no-color --format="%(if)%(HEAD)%(then)*%(else)-%(end)|%(refname:lstrip=2)" |\
  fzf --tmux 60%,border-native -d '|' --with-nth='{1} {2}' \
  --accept-nth 2 --input-label-pos=bottom \
  --bind 'ctrl-b:execute(git branch -c {q})+reload<git branch --no-color --format="%(if)%(HEAD)%(then)*%(else)-%(end)|%(refname:lstrip=2)">,ctrl-d:execute(git branch -d {2})+reload<git branch --no-color --format="%(if)%(HEAD)%(then)*%(else)-%(end)|%(refname:lstrip=2)">' \
  --input-label="C-b: create branch {q} | C-d: delete branch | Enter: checkout branch")

# git checkout "$branch" &>/dev/null || exit 1
echo "$branch"
