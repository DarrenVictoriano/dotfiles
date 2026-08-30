# Omarchy And macOS Installer Plan

## Goal

Make the dotfiles installer reliable and maintainable for exactly two supported
platforms: Omarchy and Apple Silicon macOS.

## Confirmed Decisions

- [x] Support Omarchy and Apple Silicon macOS only.
- [x] Use `$HOME/code/dotfiles` by default and allow `DOTFILES_DIR` to override it.
- [x] Clone the repository and its submodules over HTTPS.
- [x] Install each platform package manager's latest stable Bash and Zsh at
  install time; report their versions without attempting cross-platform version
  comparison or source builds.
- [x] Keep Zsh as the login shell.
- [x] Install Homebrew automatically when it is missing on macOS.
- [x] Run Omarchy's supported full update before package installation, decline
  reboot offers, and report when a later reboot is recommended.
- [x] Preserve current package lists, applications, macOS defaults, aliases, and
  Neovim behavior unless a defect blocks installation.
- [x] Do not install kubectl or Google Cloud CLI. Keep their existing aliases and
  Oh My Zsh plugins for manually managed work installations.
- [x] Fail immediately for critical bootstrap phases. Attempt all optional
  packages/apps, summarize their failures, and return a nonzero status.
- [x] Permit normal credential and shell-change prompts, but never reboot from
  the dotfiles installer.

## Implementation

### 1. Public Bootstrap

- [x] Keep `install.sh` compatible with macOS's stock Bash 3.2.
- [x] Detect only Omarchy or Darwin on `arm64`; reject plain Arch, other Linux,
  Intel macOS, and unknown systems with actionable errors.
- [x] Install Homebrew on Apple Silicon macOS when absent and initialize its
  environment for the current process.
- [x] Run `omarchy-update -y` on Omarchy without allowing a reboot during
  bootstrap.
- [x] Install or upgrade Bash, Zsh, and Git through the selected platform's
  package manager.
- [x] Move an existing checkout to sibling `dotfiles_bak`; if that name exists,
  choose a timestamped backup instead of overwriting it.
- [x] Clone `$DOTFILES_REPO_URL` into `$DOTFILES_DIR` with recursive HTTPS
  submodules, then hand off to the repository-local orchestrator using modern
  Bash.

### 2. Internal Architecture

- [x] Add one repository-local orchestrator with strict error handling and
  clearly ordered phases.
- [x] Add shared helpers for logging, critical command checks, optional failure
  collection, package installation, and platform dispatch.
- [x] Keep Omarchy and macOS package details in platform-specific scripts.
- [x] Remove obsolete generic OS/Linux dispatchers and replace the standalone
  Zsh prerequisite flow with shared Bash/Zsh setup.
- [x] Derive repository paths from script locations rather than hardcoded home
  paths or the caller's working directory.

### 3. Configuration Installation

- [x] Install Oh My Zsh and plugins as a critical, rerunnable phase.
- [x] Install common and platform-specific packages while preserving the
  existing package/app selections.
- [x] Correct package names or ordering only where the current path cannot work.
- [x] Make Stow deterministic and rerunnable: retain links already managed by
  this repository and move genuine conflicts to timestamped backups.
- [x] Use the centralized platform result for Stow package selection and Zsh
  configuration; never treat every Linux system as Omarchy.
- [x] Run mise after its configuration is stowed where the existing setup
  requires it.
- [x] Preserve the Omarchy Neovim theme integration without making macOS depend
  on Omarchy state.
- [x] Add installed Zsh to `/etc/shells` when needed and use `chsh` without a
  reboot prompt.

### 4. Repository And Documentation

- [x] Change the root and nested submodule URLs to HTTPS and synchronize them.
- [x] Update `README.md` to describe only Omarchy and Apple Silicon macOS.
- [x] Replace `curl | bash` with `/bin/bash -c "$(curl ...)"` so interactive
  prompts retain terminal input.
- [x] Document automatic Homebrew installation, the full Omarchy update, the
  checkout backup behavior, manual kubectl/gcloud ownership, and rerun safety.

### 5. Verification

- [x] Run `bash -n` over every Bash installer.
- [x] Run `zsh -n` over changed Zsh files.
- [x] Run ShellCheck and formatting checks when available; record any unavailable
  checks rather than silently skipping them.
  ShellCheck and shfmt were unavailable on the development host. Two independent
  shell reviews found no Bash-4-only syntax in the Public Bootstrap.
- [x] Smoke-test platform detection for Omarchy, Apple Silicon macOS, plain Arch,
  Intel macOS, and unsupported systems without performing real installs.
- [x] Smoke-test clean clone, existing-checkout backup collision handling,
  critical failure propagation, optional failure summaries, and repeated Stow
  behavior using temporary homes/mocks.
- [x] Verify no installer or tool manifest installs kubectl or Google Cloud CLI.
- [x] Review the final diff for unrelated package/configuration changes.

The repeatable smoke suite is `bash tests/install-smoke.sh`. An actual Apple
Silicon Mac should run it with `/bin/bash` when first available to validate the
stock Bash 3.2 runtime in addition to the completed static review.

## Resume Instructions

1. Read `CONTEXT.md` and the confirmed decisions above.
2. Inspect `git status` and preserve unrelated user changes.
3. Start at the first unchecked implementation item.
4. Mark a checkbox complete only after its implementation and relevant
   verification succeed.
5. If work stops mid-step, leave it unchecked and add a short note beneath it
   describing the blocker or partial state.
