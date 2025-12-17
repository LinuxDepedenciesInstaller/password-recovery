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
  echo -e "Please run: sudo ./password-recovery.sh"
  exit 1
fi

# 2. List available users (Including root and standard users)
echo -e "${YELLOW}Searching for available users...${NC}"
# Filter: UID 0 (root) or UID >= 1000, excluding 'nobody'
mapfile -t USERS < <(awk -F: '($3 == 0 || $3 >= 1000) && $1 != "nobody" {print $1}' /etc/passwd)

if [ ${#USERS[@]} -eq 0 ]; then
  echo -e "${RED}No users detected automatically.${NC}"
  read -p "Please enter the username manually: " TARGET_USER
else
  echo -e "Available users:"
  for i in "${!USERS[@]}"; do
    echo -e " [$i] ${USERS[$i]}"
  done

  # 3. Select user
  read -p "Enter the number of the user to reset: " USER_INDEX

  if [[ -z "${USERS[$USER_INDEX]}" ]]; then
    echo -e "${RED}Invalid selection. Exiting.${NC}"
    exit 1
  fi
  TARGET_USER="${USERS[$USER_INDEX]}"
fi

echo -e "\nTarget user selected: ${GREEN}$TARGET_USER${NC}"

# 4. Input new password
echo -en "${YELLOW}Enter new password for $TARGET_USER: ${NC}"
read -s NEW_PASS
echo ""
echo -en "${YELLOW}Confirm new password: ${NC}"
read -s NEW_PASS_CONFIRM
echo ""

# 5. Validation and Reset
if [ "$NEW_PASS" != "$NEW_PASS_CONFIRM" ]; then
  echo -e "${RED}Error: Passwords do not match. Please try again.${NC}"
  exit 1
fi

if [ -z "$NEW_PASS" ]; then
  echo -e "${RED}Error: Password cannot be empty.${NC}"
  exit 1
fi

# Resetting password using chpasswd
echo "$TARGET_USER:$NEW_PASS" | chpasswd

if [ $? -eq 0 ]; then
  echo -e "\n${GREEN}Success! Password for '$TARGET_USER' has been reset.${NC}"
else
  echo -e "\n${RED}Failed to reset password. Check system logs.${NC}"
  exit 1
fi

echo -e "\n${YELLOW}Exiting LDI Recovery Tool.${NC}"
