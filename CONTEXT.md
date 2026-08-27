# Glossary

## Bootstrap

The process that prepares a supported machine to run the Installer and obtains the
dotfiles workspace. It may update an existing clean workspace.

## Installer

The process that configures a machine from an existing dotfiles workspace. It does
not update the workspace itself.

## Platform Profile

The configuration and software specific to one supported operating environment.
The supported platform profiles are Omarchy and macOS.

## Core Profile

The shared terminal and development environment required on every supported
platform.

## Full Profile

The Core Profile plus the selected Platform Profile's applications, desktop
configuration, and operating-system preferences.

## Managed Config

A configuration path owned by a Stow package in the dotfiles workspace.

## Archival Config

Configuration retained for reference or manual restoration but not installed by
the Bootstrap or Installer.
