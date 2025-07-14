#!/bin/bash

# Website Clone Tool
# Works on Linux and Termux (Android)
# Requires: wget, tar (usually pre-installed)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if wget is installed
check_dependencies() {
    if ! command -v wget &> /dev/null; then
        echo -e "${RED}Error: wget is not installed.${NC}"
        
        # For Termux
        if [ -d "/data/data/com.termux/files/usr" ]; then
            echo -e "${YELLOW}Installing wget for Termux...${NC}"
            pkg update -y && pkg install wget -y
        else
            # For Linux
            echo -e "${YELLOW}Please install wget using your package manager:${NC}"
            echo "Debian/Ubuntu: sudo apt install wget"
            echo "Arch: sudo pacman -S wget"
            echo "Fedora: sudo dnf install wget"
            exit 1
        fi
    fi
}

clone_website() {
    local url=$1
    local output_dir=$2
    
    # Add http:// if no scheme is specified
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="http://$url"
    fi
    
    echo -e "${GREEN}Starting website clone of: ${YELLOW}$url${NC}"
    echo -e "${GREEN}Output directory: ${YELLOW}$output_dir${NC}"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Use wget to mirror the site
    wget \
        --recursive \
        --no-clobber \
        --page-requisites \
        --html-extension \
        --convert-links \
        --restrict-file-names=windows \
        --domains $(echo $url | awk -F/ '{print $3}') \
        --no-parent \
        --no-check-certificate \
        --quiet \
        --show-progress \
        -P "$output_dir" \
        "$url"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Website cloned successfully!${NC}"
        
        # Create a compressed archive
        echo -e "${YELLOW}Creating compressed archive...${NC}"
        tar -czf "${output_dir}.tar.gz" "$output_dir"
        echo -e "${GREEN}Archive created: ${YELLOW}${output_dir}.tar.gz${NC}"
    else
        echo -e "${RED}Error occurred while cloning the website.${NC}"
    fi
}

main() {
    echo -e "${GREEN}Website Clone Tool${NC}"
    echo -e "${YELLOW}------------------${NC}"
    
    check_dependencies
    
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <website-url> [output-directory]"
        echo "Example: $0 example.com my_website_clone"
        exit 1
    fi
    
    local url=$1
    local output_dir=${2:-"${url}_clone"}
    
    clone_website "$url" "$output_dir"
}

main "$@"
