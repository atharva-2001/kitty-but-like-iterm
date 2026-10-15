#!/bin/zsh
# Apply a random pastel theme (colors only — font untouched) to the current
# kitty window, and tint its tab to match, so terminals are distinguishable
# at a glance. Themes live in ~/.config/kitty/themes/ (curated set pulled
# from kitty's built-in collection: Catppuccin, Rosé Pine, Everforest, ...).
#
# Called from .zshrc on each new kitty window. Requires
# `allow_remote_control yes` in kitty.conf.

THEME_DIR="$HOME/.config/kitty/themes"

KITTEN=$(command -v kitten)
[[ -x "$KITTEN" ]] || KITTEN="/Applications/kitty.app/Contents/MacOS/kitten"
[[ -x "$KITTEN" ]] || exit 0

# Pick the pool matching the current macOS appearance. When the appearance
# changes later, theme-watcher.py re-rolls all open windows instantly.
if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
    themes=("$THEME_DIR"/dark-*.conf(N))
else
    themes=("$THEME_DIR"/light-*.conf(N))
fi
(( ${#themes} )) || exit 0

# Avoid giving this window the same theme as the previously opened one.
state="$HOME/.cache/kitty-last-random-theme"
last=""
[[ -r "$state" ]] && last=$(<"$state")
theme=${themes[RANDOM % ${#themes} + 1]}
if (( ${#themes} > 1 )); then
    while [[ "$theme" == "$last" ]]; do
        theme=${themes[RANDOM % ${#themes} + 1]}
    done
fi
mkdir -p "$HOME/.cache" && print -r -- "$theme" > "$state"

"$KITTEN" @ set-colors "$theme" 2>/dev/null || exit 0

# Tint this window's tab: accent = the theme's cursor color (or foreground), dim = color0.
accent=$(awk '$1 == "cursor" {print $2; exit}' "$theme")
[[ -n "$accent" ]] || accent=$(awk '$1 == "foreground" {print $2; exit}' "$theme")
dim=$(awk '$1 == "color0" {print $2; exit}' "$theme")
bg=$(awk '$1 == "background" {print $2; exit}' "$theme")
if [[ -n "$accent" && -n "$bg" ]]; then
    "$KITTEN" @ set-tab-color \
        active_bg="$accent" active_fg="$bg" \
        inactive_bg="${dim:-$bg}" inactive_fg="$accent" 2>/dev/null
fi
