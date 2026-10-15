# Agent install guide: kitty-but-like-iterm

You are an AI coding agent installing this kitty config for your user. Follow these steps in order.
Do not delete any user file. Stop and ask the user if a step fails or something doesn't match.

## Preconditions

1. The OS is macOS (`uname` prints `Darwin`). The theme scripts use `defaults read -g AppleInterfaceStyle`.
   On any other OS, stop and tell the user.
2. kitty is installed: `command -v kitten` works, or `/Applications/kitty.app` exists. If not, tell the user
   to install it from https://sw.kovidgoyal.net/kitty/ and stop.
3. `command -v python3` works (the theme watcher is Python).
4. The user's shell is zsh. `random-theme.sh` is a zsh script and the hook below goes in `~/.zshrc`.
   If they use another shell, tell them only the `.zshrc` hook step needs adapting.

## Steps

1. **Back up.** If `~/.config/kitty` exists, move it (do not copy and delete) to
   `~/.config/kitty.backup-<YYYYMMDD-HHMMSS>`. Tell the user the backup path.
2. **Clone.** `git clone https://github.com/atharva-2001/kitty-but-like-iterm ~/.config/kitty`
3. **Make the scripts executable.** `chmod +x ~/.config/kitty/pick-theme.sh ~/.config/kitty/random-theme.sh`
4. **Add the shell hook.** If `~/.zshrc` does not already contain `random-theme.sh`, append exactly:

   ```sh
   # kitty: give each new kitty window a random theme (colors only)
   if [[ -n "$KITTY_WINDOW_ID" && "$_KITTY_THEME_WIN" != "$KITTY_WINDOW_ID" ]]; then
     export _KITTY_THEME_WIN="$KITTY_WINDOW_ID"
     ~/.config/kitty/random-theme.sh
   fi
   ```

   Never overwrite `~/.zshrc`. Only append.
5. **Carry over personal settings.** If the backup had settings that this config doesn't
   (for example `font_family`, `font_size`, `background_opacity`), list them for the user and ask before
   adding any to the end of the new `~/.config/kitty/kitty.conf`. Do not bring back the old keybindings.
6. **Validate.** Run `~/.config/kitty/pick-theme.sh`. It must print `include theme-light.conf` or
   `include theme-dark.conf`. Run
   `python3 -c 'import sys; compile(open(sys.argv[1]).read(), sys.argv[1], "exec")' ~/.config/kitty/theme-watcher.py`.
   It must exit 0 (this writes no files).

## Finish

Tell the user:

- the backup path,
- that they must **quit kitty completely and reopen it**, because remote control and the watcher only
  load on a fresh start,
- that this config turns on `allow_remote_control yes`, which lets programs running in kitty control
  kitty, and that the README explains how to require a password instead,
- the five shortcuts to try first: `⌘D` split, `⌘⇧D` split down, `⌘T` tab, `⌘⌥←/→` move between
  splits, `⌘,` reload the config.

You cannot see their screen, so ask them to confirm that new windows get different colors.

## Uninstall

Move `~/.config/kitty` aside, move the backup back to `~/.config/kitty`, and remove the `.zshrc` block.
