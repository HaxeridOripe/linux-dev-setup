#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$HOME/.tmux.conf"
BACKUP_DIR="$HOME/.config/linux-dev-setup/backups/$(date +%Y%m%d-%H%M%S)"
SOURCE="$SCRIPT_DIR/tmux/tmux.conf"

log() {
    printf '[install-tmux] %s\n' "$*"
}

warn() {
    printf '[install-tmux] warning: %s\n' "$*" >&2
}

command -v tmux >/dev/null 2>&1 || {
    printf '[install-tmux] error: tmux is not installed. Run install.sh first.\n' >&2
    exit 1
}

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    if [[ ! -f "$TARGET" ]] || ! cmp -s "$TARGET" "$SOURCE"; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$TARGET" "$BACKUP_DIR/tmux.conf"
        log "Backed up $TARGET to $BACKUP_DIR/tmux.conf"
    fi
fi

install -Dm644 "$SOURCE" "$TARGET"
log "Installed $TARGET"

if [[ -n "${TMUX:-}" ]]; then
    if tmux source-file "$TARGET"; then
        log "Reloaded the current tmux server"
    else
        warn "The current tmux server could not be reloaded; run: tmux source-file $TARGET"
    fi
else
    log "No attached tmux client detected; the configuration will apply to new sessions"
fi
