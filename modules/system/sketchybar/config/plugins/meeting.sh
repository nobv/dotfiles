#!/usr/bin/env bash

# Read from the macOS calendar store directly. MeetingBar's own
# eventStoreProvider is "MacOS Calendar App", so this is the same source — going
# through it would only add an alias that cannot be addressed stably. Freshness
# is therefore set by Calendar.app's sync interval, not by this script.
#
# Hidden when nothing is scheduled. Note that a denied Calendar permission looks
# identical to an empty day.

source "$(dirname "$0")/../colors.sh"

MAX_TITLE=22

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
end="${span##*-}"

if [ ${#title} -gt "$MAX_TITLE" ]; then
  title="${title:0:$((MAX_TITLE - 1))}…"
fi

now_minutes=$((10#$(date '+%H') * 60 + 10#$(date '+%M')))
start_minutes=$((10#${start%%:*} * 60 + 10#${start##*:}))
end_minutes=$((10#${end%%:*} * 60 + 10#${end##*:}))
# An event crossing midnight ends "before" it starts on this scale.
[ "$end_minutes" -lt "$start_minutes" ] && end_minutes=$((end_minutes + 1440))

until_start=$((start_minutes - now_minutes))

humanise() {
  if [ "$1" -ge 60 ]; then
    printf '%dh %dm' "$(($1 / 60))" "$(($1 % 60))"
  else
    printf '%dm' "$1"
  fi
}

if [ "$until_start" -le 0 ]; then
  # Already under way — what matters is how much is left, not that it started.
  when="now ($(humanise $((end_minutes - now_minutes))) left)"
  cap="$RED"
else
  when="in $(humanise "$until_start")"
  if [ "$until_start" -le 10 ]; then cap="$ORANGE"; else cap="$PINK"; fi
fi

sketchybar --set "$NAME" label="$title  $when"
sketchybar --set "$NAME.cap" background.color="$cap"
