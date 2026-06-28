---
description: Open a Git diff in cmux's browser with difit
argument-hint: [commit-ish] [compare-with]
allowed-tools: Bash(difit:*)
---

Launch `difit` to view a Git diff in cmux's built-in browser.

`difit` starts a foreground web server; inside cmux its URL opens in cmux's
built-in browser automatically (cmux intercepts `open`). It **must** be started
in the background — otherwise it blocks this session until the server is stopped.

Steps:

1. Run `difit $ARGUMENTS` with the Bash tool and `run_in_background: true`.
   With no arguments difit diffs `HEAD`; pass-throughs work too — e.g.
   `working` (uncommitted), `staged`, `HEAD~1`, or `<base> <compare>`.
2. Read the background output until difit prints
   `🚀 difit server started on <url>` (or `No differences found`).
3. Report that URL and that it opened in cmux's browser, then stop — leave the
   server running so the diff stays open. Do **not** wait for it to exit.
