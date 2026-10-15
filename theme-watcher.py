# kitty watcher: when macOS switches between light and dark mode, instantly
# re-roll every window with a random theme from the matching pool in
# ~/.config/kitty/themes/ (light-*.conf / dark-*.conf), and retint its tab.
# Event-driven — kitty calls this per window on the OS appearance change,
# no polling involved. Wired up via `watcher theme-watcher.py` in kitty.conf.
import glob
import os
import random

THEME_DIR = os.path.expanduser('~/.config/kitty/themes')


def _first(path, key):
    try:
        with open(path) as f:
            for line in f:
                parts = line.split()
                if len(parts) >= 2 and parts[0] == key:
                    return parts[1]
    except OSError:
        pass
    return ''


def _apply_random(boss, window, is_dark):
    prefix = 'dark-' if is_dark else 'light-'
    themes = glob.glob(os.path.join(THEME_DIR, prefix + '*.conf'))
    if not themes:
        return
    theme = random.choice(themes)
    boss.call_remote_control(window, ('set-colors', f'--match=id:{window.id}', theme))
    accent = _first(theme, 'cursor')
    dim = _first(theme, 'color0')
    bg = _first(theme, 'background')
    if accent and bg:
        boss.call_remote_control(window, (
            'set-tab-color', f'--match=window_id:{window.id}',
            f'active_bg={accent}', f'active_fg={bg}',
            f'inactive_bg={dim or bg}', f'inactive_fg={accent}',
        ))


def on_color_scheme_preference_change(boss, window, data):
    _apply_random(boss, window, bool(data.get('is_dark')))
