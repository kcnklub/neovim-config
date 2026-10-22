#!/bin/bash

# Herdr Config Installer
# Installs the herdr configuration checked into this repo onto this machine.
# Keybindings mirror ~/.config/tmux/tmux.conf - see herdr/README.md
#
# Usage: scripts/install-herdr.sh [options]
#   --copy         Copy config.toml instead of symlinking it
#   --no-plugins   Skip the project-picker plugin (config.toml only)
#   --dry-run      Print what would happen, change nothing
#   -h, --help     Show this help

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$REPO_DIR/herdr"
HERDR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
PICKER_REPO="${HERDR_PICKER_REPO:-git@github.com:kcnklub/herdr-project-pickr.git}"
PICKER_REPO_HTTPS="https://github.com/kcnklub/herdr-project-pickr.git"
PICKER_DIR="${HERDR_PICKER_DIR:-$HOME/projects/herdr-project-picker}"
MIN_HERDR_VERSION="0.8.0"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

MODE="link"
INSTALL_PLUGINS=1
DRY_RUN=0
BACKUP_PATH=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

usage() {
    sed -n '3,11p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# Run a command, or just describe it under --dry-run
run() {
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "        would run: $*"
    else
        "$@"
    fi
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --copy) MODE="copy" ;;
            --no-plugins) INSTALL_PLUGINS=0 ;;
            --dry-run) DRY_RUN=1 ;;
            -h|--help) usage; exit 0 ;;
            *) print_error "Unknown option: $1"; echo; usage; exit 1 ;;
        esac
        shift
    done
}

# Compare two dotted versions; true when $1 >= $2
version_at_least() {
    [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

check_herdr() {
    if ! command -v herdr >/dev/null 2>&1; then
        print_warning "herdr is not installed or not on PATH"
        print_warning "Install it from https://herdr.dev, then re-run this script"
        print_warning "Continuing - the config will be in place when herdr arrives"
        return 0
    fi

    local version
    version="$(herdr --version 2>/dev/null | awk '{print $2}')"
    if [[ -n "$version" ]] && ! version_at_least "$version" "$MIN_HERDR_VERSION"; then
        print_warning "herdr $version is older than $MIN_HERDR_VERSION"
        print_warning "Indexed agent bindings (focus_agent) may not be supported"
    else
        print_status "Found herdr ${version:-unknown}"
    fi
}

install_config() {
    local src="$SRC_DIR/config.toml"
    local dest="$HERDR_DIR/config.toml"

    if [[ ! -f "$src" ]]; then
        print_error "Missing $src - is this repo checked out completely?"
        exit 1
    fi

    run mkdir -p "$HERDR_DIR"

    # Already the symlink we want? Nothing to do.
    if [[ "$MODE" == "link" && -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        print_status "config.toml already links to this repo"
        return 0
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        BACKUP_PATH="$dest.bak-$TIMESTAMP"
        run cp -L "$dest" "$BACKUP_PATH"
        print_status "Backed up existing config to $BACKUP_PATH"
        run rm -f "$dest"
    fi

    if [[ "$MODE" == "link" ]]; then
        run ln -s "$src" "$dest"
        print_success "Linked $dest -> $src"
    else
        run cp "$src" "$dest"
        print_success "Copied config.toml to $dest"
    fi
}

install_plugins() {
    local template="$SRC_DIR/plugins.json.template"

    if [[ $INSTALL_PLUGINS -eq 0 ]]; then
        print_status "Skipping plugins (--no-plugins)"
        return 0
    fi

    if [[ ! -f "$template" ]]; then
        print_status "No plugins.json.template in repo - skipping plugins"
        return 0
    fi

    if ! command -v git >/dev/null 2>&1; then
        print_warning "git not found - skipping the project-picker plugin"
        return 0
    fi

    # The plugin lives in its own repo; herdr only stores a path to the checkout.
    if [[ -d "$PICKER_DIR/.git" ]]; then
        print_status "project-picker already checked out at $PICKER_DIR"
    else
        print_status "Cloning project-picker into $PICKER_DIR"
        run mkdir -p "$(dirname "$PICKER_DIR")"
        if [[ $DRY_RUN -eq 0 ]]; then
            if ! git clone --quiet "$PICKER_REPO" "$PICKER_DIR" 2>/dev/null; then
                print_warning "SSH clone failed, retrying over HTTPS"
                if ! git clone --quiet "$PICKER_REPO_HTTPS" "$PICKER_DIR"; then
                    print_warning "Could not clone $PICKER_REPO_HTTPS - skipping plugin"
                    return 0
                fi
            fi
        else
            echo "        would run: git clone $PICKER_REPO $PICKER_DIR"
        fi
    fi

    # plugins.json holds absolute paths and herdr rewrites it at runtime,
    # so render a real file from the template rather than symlinking it.
    if [[ -f "$HERDR_DIR/plugins.json" ]]; then
        run cp "$HERDR_DIR/plugins.json" "$HERDR_DIR/plugins.json.bak-$TIMESTAMP"
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "        would render: $HERDR_DIR/plugins.json (PLUGIN_ROOT=$PICKER_DIR)"
    else
        sed "s|{{PLUGIN_ROOT}}|$PICKER_DIR|g" "$template" > "$HERDR_DIR/plugins.json"
        mkdir -p "$HERDR_DIR/plugins/config/project-picker"
        print_success "Wrote plugins.json pointing at $PICKER_DIR"
    fi
}

verify_config() {
    if ! command -v herdr >/dev/null 2>&1 || [[ $DRY_RUN -eq 1 ]]; then
        return 0
    fi

    print_status "Validating config"
    if herdr config check; then
        return 0
    fi

    print_error "herdr rejected the config"
    if [[ -n "$BACKUP_PATH" && -f "$BACKUP_PATH" ]]; then
        rm -f "$HERDR_DIR/config.toml"
        cp "$BACKUP_PATH" "$HERDR_DIR/config.toml"
        print_warning "Restored the previous config from $BACKUP_PATH"
    fi
    exit 1
}

reload_server() {
    if ! command -v herdr >/dev/null 2>&1 || [[ $DRY_RUN -eq 1 ]]; then
        return 0
    fi

    if herdr status server 2>/dev/null | /usr/bin/grep -q '^status: running'; then
        print_status "Reloading the running herdr server"
        herdr server reload-config >/dev/null && print_success "Config reloaded (panes untouched)"
    else
        print_status "No herdr server running - config applies on next launch"
    fi
}

print_summary() {
    echo
    print_success "herdr config installed from $REPO_DIR"
    echo
    echo "  Leader is ctrl+w (tmux-style):"
    echo "    ctrl+w v / s        split right / down"
    echo "    ctrl+w h j k l      focus pane"
    echo "    ctrl+t / n / p      new / next / previous tab"
    echo "    ctrl+alt+n / p      next / previous agent"
    echo "    ctrl+alt+1..9       jump to agent N"
    echo "    ctrl+w ?            full keybinding list"
    echo
    if [[ "$MODE" == "link" ]]; then
        echo "  config.toml is symlinked, so edits land in this repo - commit them there."
    else
        echo "  config.toml was copied; re-run without --copy to track the repo instead."
    fi
}

main() {
    parse_args "$@"
    if [[ $DRY_RUN -eq 1 ]]; then
        print_status "Dry run - nothing will be changed"
    fi
    check_herdr
    install_config
    install_plugins
    verify_config
    reload_server
    print_summary
}

main "$@"
