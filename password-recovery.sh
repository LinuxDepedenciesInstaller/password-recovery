#!/bin/bash

# --- Color Definitions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================"
echo -e "       LDI Password Recovery Tool"
echo -e "======================================${NC}\n"

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root (sudo).${NC}"
  exit 1
fi

# 2. Saisie manuelle immédiate
echo -en "${YELLOW}Enter the username to reset: ${NC}"
read TARGET_USER

# Vérification si l'utilisateur existe
if ! id "$TARGET_USER" &>/dev/null; then
    echo -e "${RED}Error: User '$TARGET_USER' does not exist on this system.${NC}"
    exit 1
fi

# 3. Saisie du mot de passe
echo -en "${YELLOW}Enter new password for $TARGET_USER: ${NC}"
read -s NEW_PASS
echo ""
echo -en "${YELLOW}Confirm new password: ${NC}"
read -s NEW_PASS_CONFIRM
echo ""

if [ "$NEW_PASS" != "$NEW_PASS_CONFIRM" ]; then
  echo -e "${RED}Error: Passwords do not match.${NC}"
  exit 1
fi

# 4. Application
echo "$TARGET_USER:$NEW_PASS" | chpasswd

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}Success! Password for '$TARGET_USER' has been reset.${NC}"
else
  echo -e "\n${RED}Failed to reset password.${NC}"
  exit 1
fi
