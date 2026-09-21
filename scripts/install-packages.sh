#!/usr/bin/env bash
set -Eeuo pipefail

log() {
    printf '[install-packages] %s\n' "$*"
}

die() {
    printf '[install-packages] error: %s\n' "$*" >&2
    exit 1
}

run_as_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        die "This step needs root privileges, but sudo is not installed."
    fi
}

if command -v apt-get >/dev/null 2>&1; then
    log "Using apt-get"
    export DEBIAN_FRONTEND=noninteractive
    run_as_root apt-get update
    run_as_root apt-get install -y --no-install-recommends git zsh tmux ca-certificates
elif command -v dnf >/dev/null 2>&1; then
    log "Using dnf"
    run_as_root dnf install -y git zsh tmux ca-certificates
elif command -v apk >/dev/null 2>&1; then
    log "Using apk"
    run_as_root apk add --no-cache git zsh tmux ca-certificates
elif command -v pacman >/dev/null 2>&1; then
    log "Using pacman"
    run_as_root pacman -Sy --noconfirm --needed git zsh tmux ca-certificates
else
    die "Unsupported package manager. Install git, zsh, tmux, and ca-certificates manually."
fi

for command_name in git zsh tmux; do
    command -v "$command_name" >/dev/null 2>&1 || die "$command_name was not found after installation."
done

log "Required packages are available"
