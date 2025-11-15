#!/bin/bash

# Function to install a package on Linux (Arch/Omarchy)
install_linux_pkg() {
    local pkg="$1"

    if [ -z "$pkg" ]; then
        echo "Error: No package name provided to install_linux_pkg"
        return 1
    fi

    echo "Installing $pkg on Linux..."

    local install_failed=false

    # First try Omarchy / pacman
    if command -v omarchy-pkg-add &>/dev/null; then
        if ! omarchy-pkg-add "$pkg"; then
            echo "Package '$pkg' not found via omarchy-pkg-add or installation failed."
            install_failed=true
        else
            echo "$pkg installed successfully via omarchy-pkg-add."
            return 0
        fi
    fi

    # Fall back to yay (AUR helper)
    if command -v yay &>/dev/null; then
        if ! yay -S --noconfirm --needed "$pkg"; then
            echo "Failed to install $pkg via yay."
            install_failed=true
        else
            echo "$pkg installed successfully via yay."
            return 0
        fi
    else
        echo "yay not found. Cannot attempt AUR installation for $pkg."
        install_failed=true
    fi

    if [ "$install_failed" = true ]; then
        echo "Warning: Failed to install $pkg on Linux."
    fi
}

# -----------------------
# Install PKGs
# -----------------------
install_linux_pkg "keychain"
