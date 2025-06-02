# DRAFT

mkdir ~/GitHub/
cd ~/GitHub/

git clone https://github.com/griffeth-barker/dotfiles.git

# NixOS
NIXOS_CONFIG_PATH="/etc/nixos/configuration.nix"
rm -f $NIXOS_CONFIG_PATH
ln -s ~/GitHub/nixos/configuration.nix $NIXOS_CONFIG_PATH

# Ghostty
GHOSTTY_CONFIG_PATH="~/.config/ghostty/config"
rm -f $GHOSTTY_CONFIG_PATH
ln -s ~/GitHub/dotfiles/ghostty/config $GHOSTTY_CONFIG_PATH

# VSCode
VSCODE_CONFIG_PATH="~/.config/Code/User/Settings.json"
rm -f $VSCODE_CONFIG_PATH
ln -s ~/GitHub/dotfiles/vscode/settings.json $VSCODE_CONFIG_PATH

# PowerShell
PWSH_CONFIG_PATH=""
rm -f $PWSH_CONFIG_PATH
ln -s ~/GitHub/dotfiles/powershell/Microsoft.PowerShell_profile.ps1 $PWSH_CONFIG_PATH
