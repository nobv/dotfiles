#!/usr/bin/env bash

# Reads the macOS calendar store directly. MeetingBar's own eventStoreProvider is
# "MacOS Calendar App", so this is the same source; going through it would only
# add an alias that cannot be addressed stably.
#
# Which calendars to show comes from MeetingBar's selection at runtime: this repo
# is public and calendar names are email addresses, so nothing about them can be
# committed, and MeetingBar's settings pane doubles as the picker.
#
# Never hidden — an empty item would read as "no problem" (see desk.sh), and a
# denied Calendar permission would look identical to an empty day.

source "$(dirname "$0")/../colors.sh"

MAX_TITLE=22

humanise() {
  if [ "$1" -ge 60 ]; then
    printf '%dh %dm' "$(($1 / 60))" "$(($1 % 60))"
  else
    printf '%dm' "$1"
  fi
}

calendars="$(
  defaults read leits.MeetingBar selectedCalendarIDs 2>/dev/null \
    | grep -o '"[^"]*"' | tr -d '"' | paste -sd, -
)"

# +1 so a fully spent today still shows what's next instead of going blank.
# A single-day `eventsToday` query omits the date entirely; a multi-day one
# prints it for every row, today's included, hence the date comparison below
# instead of checking for a date's absence.
event="$(
  icalBuddy -n -nc -nrd -ea -b '' -li 1 \
    ${calendars:+-ic "$calendars"} \
    -iep 'datetime,title' -df '%Y-%m-%d' -tf '%H:%M' \
    eventsToday+1 2>/dev/null
)"

icon="$ICON_CAL"
body="$PILL"

if [ -n "$event" ]; then
  title="$(printf '%s' "$event" | sed -n '1p')"
  detail="$(printf '%s' "$event" | sed -n '2p' | sed 's/^[[:space:]]*//')" # 2026-08-21 at 10:00 - 10:30

  if [ ${#title} -gt "$MAX_TITLE" ]; then
    title="${title:0:$((MAX_TITLE - 1))}…"
  fi

  case "$detail" in
  *' at '*)
    event_date="${detail%% at *}"
    span="$(printf '%s' "${detail#* at }" | tr -d '[:space:]')" # 10:00-10:30
    ;;
  *)
    event_date="$(date '+%Y-%m-%d')"
    span="$(printf '%s' "$detail" | tr -d '[:space:]')"
    ;;
  esac
  start="${span%%-*}"
  end="${span##*-}"

  if [ "$event_date" = "$(date '+%Y-%m-%d')" ]; then
    now_minutes=$((10#$(date '+%H') * 60 + 10#$(date '+%M')))
    start_minutes=$((10#${start%%:*} * 60 + 10#${start##*:}))
    end_minutes=$((10#${end%%:*} * 60 + 10#${end##*:}))
    # An event crossing midnight ends "before" it starts on this scale.
    [ "$end_minutes" -lt "$start_minutes" ] && end_minutes=$((end_minutes + 1440))

    until_start=$((start_minutes - now_minutes))

    if [ "$until_start" -le 0 ]; then
      # Already under way — what matters is how much is left, not that it started.
      label="$title  now ($(humanise $((end_minutes - now_minutes))) left)"
      cap="$RED"
    else
      label="$title  in $(humanise "$until_start")"
      if [ "$until_start" -le 10 ]; then cap="$ORANGE"; else cap="$PINK"; fi
    fi
  else
    # The range is only two days deep, so a date that isn't today is tomorrow.
    cap="$COMMENT"
    label="$title  tomorrow $start"
  fi
elif [ -n "$(icalBuddy calendars 2>/dev/null)" ]; then
  cap="$COMMENT"
  label="no events"
else
  icon="$ICON_WARN"
  cap="$RED"
  body="$PILL_WARN"
  label="calendar?"
fi

sketchybar --set "$NAME" label="$label"
sketchybar --set "$NAME.cap" icon="$icon" background.color="$cap"
sketchybar --set "$NAME.pill" background.color="$body"
