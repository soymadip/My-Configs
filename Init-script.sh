#!/bin/bash
set -e

#---------------------- USER CONFIGS --------------------------------------------------------------

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
    "archlinux-tweak-tool"
    "pfetch-rs-bin"
)


fonts_directory="Assets/fonts"
system_fonts_directory=".fonts"



#-------------------------------------------- SCRIPT START -----------------------------------------------

# Color codes for better visuals
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
echo -e "${YELLOW}Starting script......${NC}"


# Function to display headers & footers
print_header() {
    echo -e "${YELLOW}-----------------------------------------------${NC}"
    echo -e "${GREEN}$1${NC}"
}

print_footer() {
    echo -e "${GREEN}$1${NC}"
    echo -e "${YELLOW}-----------------------------------------------${NC}"
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




# Resize swap file:
read -p "Do you wanna Resize your swapfile? [you must have already have a swapfile] (y/n):"   rsz_swapf
if [ "$rsz_swapf" == "y" ] || [ "$rsz_swapf" == "Y" ] || [ -z "$rsz_swapf" ]; then
  print_header "Resizing Swapfile:"
  sudo swapoff -a 
  sudo dd if=/dev/zero of=/swapfile bs=1G count=5 
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo -e "${YELLOW}Total ammount of swapfile:${NC}"
  grep SwapTotal /proc/meminfo
  print_footer "Swapfile Resized to 5.4 GB."
else
    echo -e "${RED}swapfile size change skipped.${NC}"
fi




# Installing fonts:
print_header "Installing custom Fonts"
current_directory=$(pwd)
pushd ~
cp -r "$current_directory/$fonts_directory"/* "$system_fonts_directory"/
popd
sudo fc-cache -f -v
print_footer "Fonts are installed."





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
    print_footer "Update complete."
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
    print_footer "AUR packages installed."
else
    echo -e "${RED}Packages' Installation skipped.${NC}"
fi





# Switching to ZSH Shell:
read -p "Do you want to switch to Zsh shell? (y/n): " confirm_shell
if [ "$confirm_shell" == "y" ] || [ "$confirm_shell" == "Y" ] || [ -z "$confirm_shell" ]; then
    print_header "Changing shell"
    echo -e "${YELLOW}Checking if ZSH is installed${NC}"
    check_dependency zsh
    echo -e "${YELLOW}Changing SHELL to ZSH${NC}"
    chsh -s $(which zsh)
    echo -e "${GREEN}Shell changed for current user.${NC}"
    print_footer "Log out and log back again for changes to take effect."
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
