#!/usr/bin/env bash

# The next calendar event, and how long until it starts.
#
# Reads the macOS calendar store through icalBuddy rather than mirroring
# MeetingBar's menu-bar rendering. Two reasons: an alias can only address
# MeetingBar as `Control Center,Item-0(N)`, a position index that shifts with
# menu-bar order and silently starts pointing at another app; and an alias keeps
# that app's colours, which is the one thing that cannot be fixed from here.
#
# No data is lost by not going through MeetingBar — its own eventStoreProvider is
# "MacOS Calendar App", so it reads exactly this store. Freshness is therefore a
# property of the Calendar sync interval, not of this script; that interval is a
# setting in Calendar.app (15 minutes by default, which is what made Google events
# feel stale here).
#
# Hidden entirely when nothing is scheduled — an empty pill would be noise.

source "$(dirname "$0")/../colors.sh"

MAX_TITLE=22

# -n  from now on          -ea  skip all-day events
# -nc no calendar names    -b   no bullet
# -li 1 next one only      -iep title first, then the time span
event="$(
  icalBuddy -n -nc -nrd -ea -b '' -li 1 \
    -iep 'datetime,title' -df '' -tf '%H:%M' \
    eventsToday 2>/dev/null
)"

if [ -z "$event" ]; then
  sketchybar --set "$NAME.pill" drawing=off
  exit 0
fi
sketchybar --set "$NAME.pill" drawing=on

title="$(printf '%s' "$event" | sed -n '1p')"
span="$(printf '%s' "$event" | sed -n '2p' | tr -d '[:space:]')" # 12:00-13:00
start="${span%%-*}"

if [ ${#title} -gt "$MAX_TITLE" ]; then
  title="${title:0:$((MAX_TITLE - 1))}…"
fi

now_minutes=$((10#$(date '+%H') * 60 + 10#$(date '+%M')))
start_minutes=$((10#${start%%:*} * 60 + 10#${start##*:}))
until_start=$((start_minutes - now_minutes))

if [ "$until_start" -le 0 ]; then
  # -n includes an event already under way; say so rather than counting up.
  when="now"
  cap="$RED"
elif [ "$until_start" -lt 60 ]; then
  when="in ${until_start}m"
  # Under ten minutes is the point where it stops being background information.
  if [ "$until_start" -le 10 ]; then cap="$ORANGE"; else cap="$PINK"; fi
else
  when="in $((until_start / 60))h $((until_start % 60))m"
  cap="$PINK"
fi

sketchybar --set "$NAME" label="$title  $when"
sketchybar --set "$NAME.cap" background.color="$cap"
