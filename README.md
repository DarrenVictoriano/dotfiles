# Dotfiles

Personal dotfiles for exactly two supported platforms:

- Omarchy
- Apple Silicon macOS

Other Linux distributions, plain Arch installations, and Intel Macs are not
supported.

## Installation

Run the public bootstrap from a terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DarrenVictoriano/dotfiles/main/install.sh)"
```

The bootstrap performs these foundational steps before running the repository
setup:

- On Omarchy, update Omarchy and system packages through the supported updater.
- On Apple Silicon macOS, install Homebrew when it is missing.
- Install or upgrade to the latest stable Bash and Zsh packaged by the platform.
- Keep Zsh as the login shell without rebooting the machine.
- Move an existing `$HOME/code/dotfiles` checkout to `dotfiles_bak`, using a
  timestamped suffix rather than overwriting an existing backup.
- Clone this repository and its submodules over HTTPS.

Set `DOTFILES_DIR` to use a checkout path other than `$HOME/code/dotfiles`.

The installer may ask for credentials for package installation, `/etc/shells`,
or `chsh`. Open a new login shell after setup. If the Omarchy update replaced
components that require a reboot, the installer reports that recommendation but
does not reboot automatically.

## Work CLIs

kubectl and Google Cloud CLI are intentionally not installed. Their aliases and
Oh My Zsh plugins remain configured for machines where those tools are installed
manually.

## Bat Theme

Build the Bat theme cache after the first installation:

```bash
bat cache --build
```
