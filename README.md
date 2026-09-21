# linux-dev-setup

Install a small zsh and tmux setup for Linux development environments, including VS Code Dev Containers.

## What it installs

- `git`, `zsh`, `tmux`, and CA certificates using the detected package manager
- Oh My Zsh, when it is not already present
- `~/.zshrc`
- `~/.config/linux-dev-setup/aliases.zsh`
- `~/.tmux.conf`

Existing `.zshrc` and `.tmux.conf` files are backed up under:

```text
~/.config/linux-dev-setup/backups/<timestamp>/
```

The installer is intended to be run as the target user, without `sudo`:

```bash
git clone https://github.com/YOUR_NAME/linux-dev-setup.git
cd linux-dev-setup
./install.sh
```

The package installation step uses `sudo` only when it needs root privileges. Supported package managers are `apt-get`, `dnf`, `apk`, and `pacman`.

After installation, start a new terminal or run:

```bash
exec zsh
```

For tmux:

```bash
tmux new -s work
```

The prefix is `Ctrl-a`. Detach with `Ctrl-a d`, then reattach with:

```bash
tmux attach -t work
```

## Notes

- The zsh configuration safely skips Oh My Zsh if the clone fails or is not available yet.
- The installer does not kill an existing tmux server. If a server is already attached, it attempts to reload the configuration in that server.
- Review the scripts before running a copy downloaded from the internet. Pin a release or commit in automation when reproducibility matters.
