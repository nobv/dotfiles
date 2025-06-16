#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Profile swither
# @raycast.mode compact 
# @raycast.packageName nobv
#
# Optional parameters:
# @raycast.icon ⚡
# @raycast.argument1 {"type": "dropdown", "placeholder": "Select Profile", "data": [{"title": "Private", "value": "Default"}, {"title": "anyflow", "value": "anyflow"}]}

flashspace profile "$1"
flashspace workspace --number 1
echo "Switched profile to $1"
