#!/bin/bash
set -e

#---------------------- Packages To Install --------------------------------------------------------------

pacman_packages=(
    "zsh"
    "libdbusmenu-glib"
    "appmenu-gtk-module"
    "libappindicator-gtk3"
    "trash-cli"
    "rsync"
    "kup"
    "kdeplasma-addons"
    "packagekit-qt5"
    "xdg-desktop-portal"
    "kdialog"
    "spectacle"
    "ktorrent"
    "neovim"
    "xclip"
    "syncthing"
    "libreoffice-fresh"
    "mpv"
    "vscodium"
    "vscodium-marketplace"
    "ventoy"
    "simplescreenrecorder"
    "librewolf"
    "obsidian"
    "brave"
    "64gram-desktop"
    "paru"
)

aur_packages=(
    "kwin-bismuth-bin"
    "pfetch-rs-bin"
    "archlinux-tweak-tool"
)


fonts_directory="Assets/fonts"
system_fonts_directory="usr/share/fonts"



#-------------------------------------------- SCRIPT START -----------------------------------------------

# Color codes for better visuals
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${YELLOW}Starting script......${NC}"


# Function to display headers
print_header() {
    echo -e "${GREEN}-----------------------------------------------${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}-----------------------------------------------${NC}"
}


# Check if a dependency is installed
check_dependency() {
    local dependency=$1
    if ! command -v "$dependency" &> /dev/null; then
        echo -e "${RED}Error: $dependency is not installed.${NC}"
        read -p "Do you want to install $dependency? (y/n): " install_confirm
        if [ "$install_confirm" == "y" ] || [ "$install_confirm" == "Y" ]; then
            sudo pacman -S --noconfirm "$dependency"
            echo -e "${GREEN}$dependency installed.${NC}"
        else
            echo -e "${RED}$dependency not installed. Please install it before running this script.${NC}"
            exit 1
        fi
    fi
}




# Installing chaotic-AUR:
read -p "Do you want to install chaotic-AUR? (y/n): " confirm_aur
if [ "$confirm_aur" == "y" ] || [ "$confirm_aur" == "Y" ] || [ -z "$confirm_aur" ]; then
    print_header "Installing chaotic AUR"
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    echo -e "${GREEN}Updating Repositories...${NC}"
    sudo pacman -Syu
    echo -e "${GREEN}Update complete.${NC}"
else
    echo -e "${RED}AUR Installation skipped.${NC}"
fi




# Installing Apps:
read -p "Do you want to install apps? (y/n): " confirm_pkgs
if [ "$confirm_pkgs" == "y" ] || [ "$confirm_pkgs" == "Y" ] || [ -z "$confirm_pkgs" ]; then
    # Repo:
    print_header "Installing Repo packages"
    sudo pacman -S --noconfirm "${pacman_packages[@]}"
    echo -e "${GREEN}Repo packages installed.${NC}"
    # AURs:
    echo -e "${YELLOW}Installing AUR packages,\nPlease carefully select options when asked:${NC}"
    yay -S "${aur_packages[@]}"
    echo -e "${GREEN}AUR packages installed.${NC}"
else
    echo -e "${RED}Packages' Installation skipped.${NC}"
fi





# Installing fonts:
print_header "Installing custom Fonts"
sudo cp -r "$fonts_directory"/* "$system_fonts_directory"
sudo fc-cache -f -v
echo -e "${GREEN}Fonts are installed.${NC}"




# Switching to ZSH Shell:
read -p "Do you want to switch to Zsh shell? (y/n): " confirm_shell
if [ "$confirm_shell" == "y" ] || [ "$confirm_shell" == "Y" ] || [ -z "$confirm_shell" ]; then
    echo -e "${YELLOW}Checking if ZSH is installed${NC}"
    check_dependency zsh
    echo -e "${YELLOW}Changing SHELL to ZSH${NC}"
    chsh -s $(which zsh)
    echo -e "${GREEN}Shell changed for current user.${NC}"
    echo -e "${RED}Log out and log back again for changes to take effect.${NC}"
else
    echo -e "${RED}Shell change skipped.${NC}"
fi




# Done
echo -e "${YELLOW}Script completed.${NC}\nReboot is recommended, Do you wanna Reboot? (y/n)${NC}"
read -p "=>" cfrm_reboot
if [ "$cfrm_reboot" == "y" ] || [ "$cfrm_reboot" == "Y" ] || [ -z "$cfrm_reboot" ]; then
    sudo reboot
else
    echo -e "${GREEN}Ok, Enjoy your system! and don't forget to reboot later..${NC}"
fi
