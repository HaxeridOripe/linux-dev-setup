#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_CONFIG_DIR="$HOME/.config/linux-dev-setup"
BACKUP_DIR="$ZSH_CONFIG_DIR/backups/$(date +%Y%m%d-%H%M%S)"

log() {
    printf '[install-zsh] %s\n' "$*"
}

warn() {
    printf '[install-zsh] warning: %s\n' "$*" >&2
}

die() {
    printf '[install-zsh] error: %s\n' "$*" >&2
    exit 1
}

backup_if_needed() {
    local target="$1"
    local source="$2"

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -f "$target" && -f "$source" ]] && cmp -s "$target" "$source"; then
            return
        fi
        mkdir -p "$BACKUP_DIR"
        cp -a "$target" "$BACKUP_DIR/$(basename "$target")"
        log "Backed up $target to $BACKUP_DIR"
    fi
}

command -v zsh >/dev/null 2>&1 || die "zsh is not installed. Run install.sh first."
command -v git >/dev/null 2>&1 || die "git is not installed. Run install.sh first."

mkdir -p "$ZSH_CONFIG_DIR"

OMZ_DIR="$HOME/.oh-my-zsh"
if [[ ! -d "$OMZ_DIR" ]]; then
    log "Installing Oh My Zsh"
    if ! git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"; then
        warn "Could not clone Oh My Zsh. The zsh configuration will still be installed."
    fi
else
    log "Oh My Zsh already exists; leaving it unchanged"
fi

backup_if_needed "$HOME/.zshrc" "$SCRIPT_DIR/zsh/zshrc"
install -Dm644 "$SCRIPT_DIR/zsh/zshrc" "$HOME/.zshrc"

backup_if_needed "$ZSH_CONFIG_DIR/aliases.zsh" "$SCRIPT_DIR/zsh/aliases.zsh"
install -Dm644 "$SCRIPT_DIR/zsh/aliases.zsh" "$ZSH_CONFIG_DIR/aliases.zsh"

ZSH_BIN="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 || true)"
if [[ "$CURRENT_SHELL" != "$ZSH_BIN" ]]; then
    if command -v chsh >/dev/null 2>&1; then
        if chsh -s "$ZSH_BIN"; then
            log "Default shell changed to $ZSH_BIN"
        else
            warn "Could not change the default shell automatically. Run: chsh -s $ZSH_BIN"
        fi
    else
        warn "chsh is unavailable. Run manually: chsh -s $ZSH_BIN"
    fi
fi

log "Installed $HOME/.zshrc and $ZSH_CONFIG_DIR/aliases.zsh"
