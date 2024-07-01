#!/usr/bin/env sh

osascript -e 'tell application "System Events" to delete login item "Morgen"';
osascript -e 'tell application "System Events" to make login item at end with properties {name: "Morgen",path:"$out/Applications/Morgen.app", hidden:false}'
