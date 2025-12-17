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

# 2. List ONLY root and real users (UID 0 or UID >= 1000)
echo -e "${YELLOW}Searching for available users...${NC}"
# Filtrage : UID 0 (root) et UID >= 1000 (utilisateurs normaux)
mapfile -t USERS < <(awk -F: '($3 == 0 || $3 >= 1000) && $1 != "nobody" {print $1}' /etc/passwd)

if [ ${#USERS[@]} -eq 0 ]; then
  echo -e "${RED}No users detected.${NC}"
  exit 1
fi

echo -e "Available users:"
for i in "${!USERS[@]}"; do
  echo -e " [$i] ${USERS[$i]}"
done
echo ""

# 3. Selection
read -p "Enter the number of the user to reset: " USER_INDEX

if [[ -z "${USERS[$USER_INDEX]}" ]]; then
  echo -e "${RED}Invalid selection. Exiting.${NC}"
  exit 1
fi

TARGET_USER="${USERS[$USER_INDEX]}"
echo -e "\nTarget user selected: ${GREEN}$TARGET_USER${NC}"

# 4. Password Input
echo -en "${YELLOW}Enter new password for $TARGET_USER: ${NC}"
read -s NEW_PASS
echo ""
echo -en "${YELLOW}Confirm new password: ${NC}"
read -s NEW_PASS_CONFIRM
echo ""

# 5. Validation and Reset
if [ "$NEW_PASS" != "$NEW_PASS_CONFIRM" ]; then
  echo -e "${RED}Error: Passwords do not match.${NC}"
  exit 1
fi

if [ -z "$NEW_PASS" ]; then
  echo -e "${RED}Error: Password cannot be empty.${NC}"
  exit 1
fi

# Apply change
echo "$TARGET_USER:$NEW_PASS" | chpasswd

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}Success! Password for '$TARGET_USER' has been reset.${NC}"
else
  echo -e "\n${RED}Failed to reset password.${NC}"
  exit 1
fi

echo -e "\n${YELLOW}Exiting LDI Recovery Tool.${NC}"
