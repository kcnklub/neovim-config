#!/bin/bash

# Gruvbox Theme Toggle Script
# Toggles between light and dark Gruvbox themes for Neovim, Ghostty, and provides Claude Code instructions

set -e

# File paths
NVIM_COLORS="/home/kyle/.config/nvim/after/plugin/colors.lua"
GHOSTTY_CONFIG="/home/kyle/.config/ghostty/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect current theme from Neovim config
detect_current_theme() {
    if [[ -f "$NVIM_COLORS" ]]; then
        if grep -q 'vim.o.background = "light"' "$NVIM_COLORS"; then
            echo "light"
        elif grep -q 'vim.o.background = "dark"' "$NVIM_COLORS"; then
            echo "dark"
        else
            echo "unknown"
        fi
    else
        echo "missing"
    fi
}

# Function to toggle Neovim theme
toggle_neovim_theme() {
    local target_theme="$1"

    if [[ ! -f "$NVIM_COLORS" ]]; then
        print_error "Neovim colors file not found: $NVIM_COLORS"
        return 1
    fi

    if [[ "$target_theme" == "dark" ]]; then
        sed -i 's/vim.o.background = "light"/vim.o.background = "dark"/' "$NVIM_COLORS"
        print_success "Neovim theme set to dark"
    else
        sed -i 's/vim.o.background = "dark"/vim.o.background = "light"/' "$NVIM_COLORS"
        print_success "Neovim theme set to light"
    fi
}

# Function to toggle Ghostty theme
toggle_ghostty_theme() {
    local target_theme="$1"

    if [[ ! -f "$GHOSTTY_CONFIG" ]]; then
        print_error "Ghostty config file not found: $GHOSTTY_CONFIG"
        return 1
    fi

    if [[ "$target_theme" == "dark" ]]; then
        sed -i 's/theme = GruvboxLight/theme = GruvboxDark/' "$GHOSTTY_CONFIG"
        print_success "Ghostty theme set to GruvboxDark"
    else
        sed -i 's/theme = GruvboxDark/theme = GruvboxLight/' "$GHOSTTY_CONFIG"
        print_success "Ghostty theme set to GruvboxLight"
    fi
}

# Function to provide Claude Code instructions
claude_code_instructions() {
    local target_theme="$1"

    print_status "Claude Code theme switching:"
    if [[ "$target_theme" == "dark" ]]; then
        echo "  Run: /config theme dark"
    else
        echo "  Run: /config theme light"
    fi
}

# Main function
main() {
    echo "=== Gruvbox Theme Toggle ==="

    # Detect current theme
    current_theme=$(detect_current_theme)

    case "$current_theme" in
        "light")
            target_theme="dark"
            print_status "Current theme: Light → Switching to Dark"
            ;;
        "dark")
            target_theme="light"
            print_status "Current theme: Dark → Switching to Light"
            ;;
        "unknown")
            print_warning "Could not detect current theme from Neovim config"
            print_status "Defaulting to Dark theme"
            target_theme="dark"
            ;;
        "missing")
            print_error "Neovim colors file not found: $NVIM_COLORS"
            exit 1
            ;;
    esac

    echo

    # Toggle applications
    print_status "Updating application themes..."

    # Toggle Neovim
    if toggle_neovim_theme "$target_theme"; then
        nvim_success=true
    else
        nvim_success=false
    fi

    # Toggle Ghostty
    if toggle_ghostty_theme "$target_theme"; then
        ghostty_success=true
    else
        ghostty_success=false
    fi

    echo

    # Claude Code instructions
    claude_code_instructions "$target_theme"

    echo

    # Summary
    print_status "Theme toggle summary:"
    if [[ "$nvim_success" == "true" ]]; then
        echo "  ✓ Neovim: Switched to $target_theme"
    else
        echo "  ✗ Neovim: Failed to switch"
    fi

    if [[ "$ghostty_success" == "true" ]]; then
        echo "  ✓ Ghostty: Switched to $target_theme"
    else
        echo "  ✗ Ghostty: Failed to switch"
    fi

    echo "  ℹ Claude Code: Manual command required (see above)"

    if [[ "$ghostty_success" == "true" ]]; then
        echo
        print_status "Press Ctrl+Shift+, in Ghostty to reload config and see theme changes"
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--help]"
        echo "Toggles Gruvbox theme between light and dark for Neovim, Ghostty, and provides Claude Code instructions"
        exit 0
        ;;
    *)
        main
        ;;
esac