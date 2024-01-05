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
system_fonts_directory=".fonts" #for only current user


swap_file="/swapfile"
swap_file_size="6G"



#-------------------------------------------- SCRIPT START -----------------------------------------------

# Color codes for better visuals
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BLUE='\033[38;5;67m'
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

log() { 
    echo -e "->${BLUE} $1${NC}"
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
            echo -e "${RED}$dependency is not installed. Please install it before running this script.${NC}"
            exit 1
        fi
    fi
}




# Resize swap file:
echo -e "Do you wanna Create/Resize your swapfile? (y/n)\n(Your swap file will be of ${swap_file_size}B)"
read -p "=>"   rsz_swapf
if [ "$rsz_swapf" == "y" ] || [ "$rsz_swapf" == "Y" ] || [ -z "$rsz_swapf" ]; then
    if [ -f "$swap_file" ]; then
        print_header "Swapfile already exists. Resizing to $swap_file_size..."
        log "turning off swaps"
        sudo swapoff -a
        log "removing already present swapfile."
        sudo rm "$swap_file"
    else
        print_header "Creating swapfile of size $swap_file_size..."
    fi
    log "creating new file of ${swap_file_size}B for swap."
    sudo fallocate -l "$swap_file_size" "$swap_file"
    log "changing permissions."
    sudo chmod 600 "$swap_file"
    log "making the ${swap_file} a swapfile."
    sudo mkswap "$swap_file"
    log "turning new swapfile on"
    sudo swapon "$swap_file"
    log "please check if everything is good:"
    swapon --show
    print_footer "Swapfile created and activated."
else
    echo -e "${RED}swapfile size change skipped.${NC}"
fi




# Installing fonts:
print_header "Installing custom Fonts......"
current_directory=$(pwd)
pushd ~
log "copying fonts to ~/$system_fonts_directory."
cp -r "$current_directory/$fonts_directory"/* "$system_fonts_directory"/
popd
log "Rebuilding font cache."
sudo fc-cache -f -v
print_footer "Fonts are installed......"





# Installing chaotic-AUR:
read -p "Do you want to install chaotic-AUR? (y/n): " confirm_aur
if [ "$confirm_aur" == "y" ] || [ "$confirm_aur" == "Y" ] || [ -z "$confirm_aur" ]; then
    print_header "Installing chaotic AUR"
    log "Appending keys."
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    log "Adding repo to /etc/pacman.conf."
    echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    log "Updating Repositories."
    sudo pacman -Syu
    log "Update complete."
    print_footer "Chaotic AUR is installed."
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
    log "Checking if ZSH is installed."
    check_dependency zsh
    log "zsh is installed."
    log "Changing SHELL to ZSH.."
    chsh -s $(which zsh)
    log "Shell changed for current user."
    print_footer "Log out and log back again for changes to take effect."
else
    echo -e "${RED}Shell change skipped.${NC}"
fi




# Done
echo -e "${YELLOW}Script completed.${NC}\n${RED}Reboot is recommended, Do you wanna Reboot? (y/n)${NC}"
read -p "=>" cfrm_reboot
if [ "$cfrm_reboot" == "y" ] || [ "$cfrm_reboot" == "Y" ] || [ -z "$cfrm_reboot" ]; then
    log "rebooting..."
    sudo reboot
else
    echo -e "${GREEN}Ok, Enjoy your system! and don't forget to reboot later..${NC}"
fi