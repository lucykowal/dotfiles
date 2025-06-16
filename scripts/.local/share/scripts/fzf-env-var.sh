#!/bin/bash

tmux capture-pane -CJp -S -400 |\
  rg -oe '\$[^\d {(\[][A-Za-z_\d]*' |\
  awk '!seen[$0]++' |\
  tac |\
  fzf --tmux 60%,border-native -m -1 -0 |\
  xargs tmux send-keys -l

