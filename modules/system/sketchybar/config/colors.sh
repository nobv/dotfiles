#!/usr/bin/env bash

# Dracula, matching Ghostty and tmux. Sourced by sketchybarrc and by every plugin
# (a plugin is a separate process and inherits none of sketchybarrc's variables).

# The bar itself draws nothing; the pills float over the wallpaper.
export BAR_BG=0x00000000
export PILL=0xf044475a
export PILL_WARN=0xb0ff5555
export FG=0xfff8f8f2
export COMMENT=0xff6272a4
export CAP_FG=0xff282a36 # text on a coloured cap

# One hue per kind of information.
export PURPLE=0xffbd93f9 # desk
export PINK=0xffff79c6   # next meeting
export CYAN=0xff8be9fd   # memory
export GREEN=0xff50fa7b  # cpu
export ORANGE=0xffffb86c # temperature
export YELLOW=0xfff1fa8c # battery
export RED=0xffff5555    # desync

# Escapes, not the characters themselves: these are Private Use Area codepoints
# and get silently dropped by editors and tooling, leaving empty strings that
# still look correct in a diff. Every one is verified present in
# HackGenConsoleNF-Bold.ttf — nf-fa-memory moved in Nerd Fonts v3, so the old
# U+F538 is genuinely absent.
export ICON_APPLE=$'\xef\x85\xb9'       # U+F179 apple
export ICON_APP=$'\xef\x8b\x90'         # U+F2D0 window_maximize
export ICON_DESK=$'\xef\x84\x88'        # U+F108 desktop
export ICON_WARN=$'\xef\x81\xb1'        # U+F071 warning
export ICON_CAL=$'\xef\x81\xb3'         # U+F073 calendar
export ICON_MEM=$'\xee\xbf\x85'         # U+EFC5 memory (v3 location)
export ICON_CPU=$'\xef\x8b\x9b'         # U+F2DB microchip
export ICON_TEMP=$'\xef\x8b\x89'        # U+F2C9 thermometer_half
export ICON_BATT=$'\xef\x89\x81'        # U+F241 battery_three_quarters
export ICON_BATT_CHARGE=$'\xef\x83\xa7' # U+F0E7 bolt
export ICON_BATT_HOLD=$'\xef\x87\xa6'   # U+F1E6 plug
export ICON_CLOCK=$'\xef\x80\x97'       # U+F017 clock_o
