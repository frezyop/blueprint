#!/bin/bash

# -----------------------------------------------------
#  Blueprint Auto Installer
#  Clean UI • Animations • Stable Spinner • ASCII Art
# -----------------------------------------------------

# Colors
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
RESET="\e[0m"

# ASCII Art Banner
banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"

           _____  _____   ____  _   _     _____ _   _  _____ _______       _      _       ______ _____  
     /\   |  __ \|  __ \ / __ \| \ | |   |_   _| \ | |/ ____|__   __|/\   | |    | |    |  ____|  __ \ 
    /  \  | |  | | |  | | |  | |  \| |     | | |  \| | (___    | |  /  \  | |    | |    | |__  | |__) |
   / /\ \ | |  | | |  | | |  | | . ` |     | | | . ` |\___ \   | | / /\ \ | |    | |    |  __| |  _  / 
  / ____ \| |__| | |__| | |__| | |\  |    _| |_| |\  |____) |  | |/ ____ \| |____| |____| |____| | \ \ 
 /_/    \_\_____/|_____/ \____/|_| \_|   |_____|_| \_|_____/   |_/_/    \_\______|______|______|_|  \_\
                                                                                                       
EOF
    echo -e "${RESET}"
}

# Spinner Animation (Fixed loop trap)
spinner() {
    local pid=$1
    local delay=0.1
    local spin=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    local i=0

    # The index logic prevents the spinner from waiting 
    # for a full for-loop if the process finishes early.
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${MAGENTA}Installing... ${spin[i]}${RESET}"
        ((i = (i + 1) % 10))
        sleep $delay
    done
}

# Run Banner
banner

echo -e "${YELLOW}🔍 Searching for .blueprint files...${RESET}"
sleep 1

# Detect blueprint files safely (ignores empty matches)
shopt -s nullglob
FILES=(*.blueprint)
shopt -u nullglob

if (( ${#FILES[@]} == 0 )); then
    echo -e "${RED}❌ No .blueprint files found!${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Found ${#FILES[@]} blueprint file(s):${RESET}"
echo ""

i=1
for file in "${FILES[@]}"; do
    echo -e "  ${CYAN}$i.${RESET} $file"
    ((i++))
done
echo ""

# Fixed colored prompt
echo -ne "${YELLOW}Do you want to install all blueprints? (y/n): ${RESET}"
read -r confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${RED}Cancelled.${RESET}"
    exit 0
fi

echo ""
echo -e "${BLUE}⚡ Starting installation...${RESET}"
echo ""

# Install loop
for f in "${FILES[@]}"; do
    echo -e "${CYAN}➡ Installing: ${MAGENTA}$f${RESET}"

    # Redirect output to a log file so it doesn't break the UI spinner
    LOG_FILE="install_${f}.log"
    blueprint -install "$f" > "$LOG_FILE" 2>&1 &
    installer_pid=$!

    # Run the spinner while waiting for the background job
    spinner $installer_pid
    
    # Check if the installation was actually successful
    if wait "$installer_pid"; then
        printf "\r${GREEN}✓ Done!${RESET}                              \n"
    else
        printf "\r${RED}❌ Failed! Check $LOG_FILE for details.${RESET}\n"
    fi
    echo ""
done

echo -e "${GREEN}🎉 All blueprints processed!${RESET}"
echo ""
echo -e "${BLUE}✨ Thank you for using Blueprint Installer, Frezy!${RESET}"
echo ""

