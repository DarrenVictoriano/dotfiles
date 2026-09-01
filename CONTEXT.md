# Dotfiles Bootstrap

This context defines the supported machines and setup boundaries for installing
this dotfiles repository.

## Language

**Supported Platform**:
Either an Omarchy installation or an Apple Silicon Mac. Other Arch/Linux systems
and Intel Macs are unsupported.
_Avoid_: Linux, Arch, macOS

**Public Bootstrap**:
The remotely executable entry point that prepares foundational tools and obtains
a clean repository checkout.
_Avoid_: Installer, setup script

**Repository Setup**:
The setup process run from the cloned repository after the Public Bootstrap has
prepared the machine.
_Avoid_: Bootstrap

**Foundational Shells**:
The latest stable Bash and Zsh available from the Supported Platform's package
manager at installation time. Zsh is the login shell.
_Avoid_: System shell, pinned shells

**Work CLI**:
Either kubectl or Google Cloud CLI, which is installed manually and remains
outside the dotfiles bootstrap boundary.
_Avoid_: Common package
