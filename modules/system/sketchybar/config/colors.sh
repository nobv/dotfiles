#!/usr/bin/env bash

# Dracula, because Ghostty and tmux already use it. Introducing a fourth scheme
# is what makes an environment look assembled rather than chosen.
#
# Sourced by sketchybarrc and by every plugin — a plugin runs as a separate
# process, so it inherits none of sketchybarrc's variables.

export BAR_BG=0x9e282a36  # translucent Dracula background
export PILL=0x8044475a    # "current line" — the body of each pill
export PILL_WARN=0x59ff5555
export FG=0xfff8f8f2
export COMMENT=0xff6272a4 # de-emphasised text and caps
export CAP_FG=0xff282a36  # text on top of a coloured cap

# One hue per kind of information — the hue IS the label, which is what lets
# these read at a glance without being read.
export PURPLE=0xffbd93f9  # desk
export PINK=0xffff79c6    # next meeting
export CYAN=0xff8be9fd    # memory
export GREEN=0xff50fa7b   # cpu
export ORANGE=0xffffb86c  # temperature
export YELLOW=0xfff1fa8c  # battery
export RED=0xffff5555     # desync

# Nerd Font glyphs, written as UTF-8 escapes rather than as the characters
# themselves: these live in the Private Use Area, and pasted PUA characters get
# silently dropped by editors and tooling along the way — which is exactly how an
# earlier version of this file ended up assigning empty strings while still
# looking correct in a diff.
#
# Every codepoint below was verified present in HackNerdFont-Bold.ttf by reading
# its cmap. Nerd Fonts v3 moved part of the Font Awesome range, so this is not a
# formality: nf-fa-memory at the old U+F538 is genuinely absent, and the v3
# location U+EFC5 is used instead.
export ICON_DESK=$'\xef\x84\x88'        # U+F108 nf-fa-desktop
export ICON_WARN=$'\xef\x81\xb1'        # U+F071 nf-fa-warning
export ICON_APP=$'\xef\x8b\x90'         # U+F2D0 nf-fa-window_maximize
export ICON_CAL=$'\xef\x81\xb3'         # U+F073 nf-fa-calendar
export ICON_MEM=$'\xee\xbf\x85'         # U+EFC5 nf-fa-memory (v3 location)
export ICON_CPU=$'\xef\x8b\x9b'         # U+F2DB nf-fa-microchip
export ICON_TEMP=$'\xef\x8b\x89'        # U+F2C9 nf-fa-thermometer_half
export ICON_BATT=$'\xef\x89\x81'        # U+F241 nf-fa-battery_three_quarters
export ICON_BATT_CHARGE=$'\xef\x83\xa7' # U+F0E7 nf-fa-bolt
export ICON_BATT_HOLD=$'\xef\x87\xa6'   # U+F1E6 nf-fa-plug
export ICON_CLOCK=$'\xef\x80\x97'       # U+F017 nf-fa-clock_o
