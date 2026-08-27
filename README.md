# dotfiles

Personal dotfiles and new-laptop bootstrap for Omarchy and macOS.

## Install

The bootstrap installs Bash 5.3 or newer, clones this repository into
`~/Code/dotfiles`, and runs the full personal profile:

```bash
curl -fsSL https://raw.githubusercontent.com/DarrenVictoriano/dotfiles/main/bootstrap.sh | sh
```

Pass installer options through `sh -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/DarrenVictoriano/dotfiles/main/bootstrap.sh \
  | sh -s -- --core-only
```

The default full profile installs the core terminal/development environment plus
macOS applications and defaults or Omarchy desktop and gaming configuration.
`--core-only` installs only the core tools and common managed configs.

On macOS, application quarantine remains enabled unless explicitly disabled:

```bash
curl -fsSL https://raw.githubusercontent.com/DarrenVictoriano/dotfiles/main/bootstrap.sh \
  | sh -s -- --disable-quarantine
```

## Behavior

- Only Omarchy and macOS are supported.
- Homebrew is installed automatically on macOS.
- Zsh is installed and selected as the login shell without rebooting.
- Public repositories and submodules are fetched over HTTPS.
- An existing clean checkout is updated with `git pull --ff-only`.
- Running local `install.sh` never updates the repository.
- Existing Oh My Zsh plugins and Mise runtimes are not upgraded on reruns.
- Conflicting configs are moved under
  `~/.local/state/dotfiles/backups/<timestamp>/` before Stow runs.
- Required core failures stop immediately. Full-profile steps attempt every item
  and report all failures before returning a nonzero status.

## Local Install

From an existing checkout:

```bash
./install.sh
```

Use `./install.sh --help` to list available options. The local installer requires
Bash 5.3 or newer and will re-execute itself with Homebrew Bash when available.

## Archival Directories

These directories are intentionally not installed by Stow:

- `glazewm`: Windows configuration retained for reference.
- `pipewire_unused`: inactive PipeWire configuration.
- `raycast`: manual Raycast export retained as a backup.
