#!/bin/bash
set -e

# App Directory on Windows if running in WSL/Git Bash
APP_DIR="$LOCALAPPDATA/Klein"
if [ -z "$LOCALAPPDATA" ]; then
    # Fallback if running on purely Linux or older bash
    APP_DIR="$HOME/.config/klein"
fi
CONFIG_PATH="$APP_DIR/config.toml"

echo "==========================="
echo "  Klein IDE Setup/Config   "
echo "==========================="

if [ ! -d "$APP_DIR" ]; then
    mkdir -p "$APP_DIR"
    echo "Created application directory at $APP_DIR"
fi

prompt_configuration() {
    echo -e "\n--- Configuration ---"
    
    # Check for Git Bash installation path in default Windows locations
    if [ ! -d "/c/Program Files/Git" ] && [ ! -d "/c/Users/$USER/AppData/Local/Programs/Git" ] && ! command -v bash &> /dev/null; then
        echo "WARNING: Git Bash was not found in standard locations."
        echo "We highly recommend installing Git Bash for the best terminal experience in Klein."
        echo "You can download it from: https://gitforwindows.org/"
        read -p "Would you like to install Git Bash later? (y/n) " install_git
        if [ "$install_git" = "n" ]; then
            echo "You can continue, but terminal features might be limited."
        fi
    fi

    read -p "Enter your default workspace/projects path [Default: $HOME]: " workspace
    workspace=${workspace:-$HOME}

    if [ ! -d "$workspace" ]; then
        read -p "Path '$workspace' does not exist. Create it? (y/N) " create_ws
        if [[ "$create_ws" =~ ^[Yy]$ ]]; then
            mkdir -p "$workspace"
        else
            echo "Warning: Workspace path may be invalid."
        fi
    fi

    read -p "Enter your preferred terminal shell (bash, powershell, cmd) [Default: auto-detect]: " shell
    shell=${shell:-auto}

    cat > "$CONFIG_PATH" <<EOF
# Klein IDE Configuration
default_workspace = "$workspace"
shell = "$shell"
EOF

    echo -e "Configuration saved to $CONFIG_PATH"
}

if [[ "$1" == "--reconfigure" || "$1" == "-Reconfigure" ]]; then
    prompt_configuration
    echo -e "\nReconfiguration complete!"
    exit 0
fi

echo -e "\n--- Installation ---"
if command -v cargo &> /dev/null; then
    echo "Cargo detected. Building from source..."
    echo "Please run 'cargo install --path .' from the project root to install."
else
    echo "Cargo not detected. Please install Rust (https://rustup.rs/) or download the pre-compiled binary."
fi

prompt_configuration

echo -e "\nInstallation & Configuration Complete!"
echo "You can run this script later with '--reconfigure' to update your settings."
