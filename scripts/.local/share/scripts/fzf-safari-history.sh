#!/bin/bash

# extract history, pick URL(s), open
sqlite3 -list $HOME/Library/Safari/History.db \
  "select t.url from history_items as t \
  group by t.url \
  order by max(t.visit_count_score) desc limit 100;" \
  | fzf -m --tmux=60%,border-native --no-sort --ansi \
  | xargs open
