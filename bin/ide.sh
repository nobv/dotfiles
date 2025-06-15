#!/bin/bash

tmux split-window -h -p 80
tmux split-window -h -p 20
tmux split-window -v -p 50
tmux select-pane -t 2
