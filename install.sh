#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

log() {
    printf '[linux-dev-setup] %s\n' "$*"
}

die() {
    printf '[linux-dev-setup] error: %s\n' "$*" >&2
    exit 1
}

if [[ "${EUID}" -eq 0 && -n "${SUDO_USER:-}" ]]; then
    die "Do not run the full installer with sudo; run it as the target user instead."
fi

log "Installing system packages"
bash "$SCRIPT_DIR/scripts/install-packages.sh"

log "Installing zsh configuration"
bash "$SCRIPT_DIR/scripts/install-zsh.sh"

log "Installing tmux configuration"
bash "$SCRIPT_DIR/scripts/install-tmux.sh"

log "Setup complete"
log "Start a new terminal, or run: exec zsh"
