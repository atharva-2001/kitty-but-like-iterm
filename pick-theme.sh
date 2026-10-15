#!/bin/sh
# Emit the include line for the theme matching the current macOS appearance.
# Used by kitty's `geninclude` directive.
if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark; then
    echo "include theme-dark.conf"
else
    echo "include theme-light.conf"
fi
