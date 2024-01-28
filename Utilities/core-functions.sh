# This script contains various decorative UI elements 
# used within the main script to make sctipt more visually appiling.

#____________________________________________UI Elements___________________________________________________

# Color codes for various visuals
NC='\033[0m' # No Color/escape code
AQUA='\e[38;2;216;222;233m'
LAVENDER='\u001b[38;5;147m'
BLUE='\033[38;5;67m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'



#welcome system
welcome() {
    clear
    echo
    echo -e "${YELLOW}Welcome to Init-Script......${NC}"
}


# Log system
logger() {
    local log_message=$1
    local log_level=$2

    if [ "$log_level" == "error" ]; then
        echo -e "${RED}[X]-> $log_message${NC}"
    elif [ "$log_level" == "imp" ]; then
        echo -e "${YELLOW}[!]->${NC} ${RED}$log_message${NC}"
    elif [ "$log_level" == "inform" ]; then
        echo -e "${YELLOW}[!]-> $log_message${NC}"
    elif [ "$log_level" == "success" ]; then
        echo -e "${GREEN}[✔]-> $log_message${NC}"
    else 
        echo -e "${BLUE}[-]-> $log_message${NC}"
    fi
}

# log messages to screen
log() {
    if [ -n "$3" ]; then 
        if [ "$2" == "error" ]; then
            logger "$1${RED} <-[${NC}${3}${RED}]${NC}" "$2"
        elif [ "$2" == "inform" ] || [ "$2" == "imp" ]; then
            logger "$1${YELLOW} <-[${NC}${3}${YELLOW}]${NC}" "$2"
        elif [ "$2" == "success" ]; then
            logger "$1${GREEN} <-[${NC}${3}${GREEN}]${NC}" "$2"
        else
            logger "$1" "$2"
        fi
    else
        logger "$1" "$2"
    fi
}



# ui for individual process
prompt() {
    echo -e "${AQUA}--------------------------${NC}"
    echo -e "${LAVENDER}[?] $1${NC} (y/n)"
    read -p "|==-> " $2
}

print_footer() {
    if [ -n "$1" ]; then
        if [ "$2" == "skipped" ]; then
            echo -e "${RED}[x]-> $1${NC}"
        else
            echo -e "${GREEN}[✔]=> $1${NC}"
        fi
    fi
    echo -e "${AQUA}---------------------------------------------------------------${NC}"
    sleep 1
}



#______________________________________________Inbuilt Functions__________________________________________________



# Import all scripts from a directory
import_all() {
    local directory=$1
    local file_ext=$2
    
    for script in ${directory}/*.${file_ext}; do
        [ -e "$script" ] && [ "$(basename "$script")" != "core-functions.sh" ] && source "$script"
    done
}


# Check if a dependency is installed
check_dependency() {
    local DEPENDENCY=$1
    local REQUIRED=$2
    if ! pacman -Q "$DEPENDENCY" &> /dev/null; then
        log "Error: ${DEPENDENCY} is not installed." error "CHECKER"
        prompt "Do you want to install ${DEPENDENCY}?" confirm_install
        if [ "$confirm_install" == "y" ] || [ "$confirm_install" == "Y" ] || [ -z "$confirm_install" ]; then
            sudo pacman -S --noconfirm "$DEPENDENCY"
            log "$DEPENDENCY installed."
        else
            if [ -n "$REQUIRED" ] && [ "$REQUIRED" == "needed" ]; then
                log "${DEPENDENCY} is not installed." inform
                print_footer "Please install it before running this." skip
                exit 1
            else
                log "${DEPENDENCY} is not installed." inform "CHECKER"
            fi
        fi
    else
        log "${DEPENDENCY} is installed in system." success
    fi
}

