#!/bin/bash

# Set colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

log() {
  local level=$1
  local message=$2

  case $level in
    DEBUG) echo -e "${GREEN}[DEBUG]${RESET} ${message}" ;;
    INFO) echo -e "${BLUE}[INFO ]${RESET} ${message}" ;;
    WARNING) echo -e "${YELLOW}[WARN ]${RESET} ${message}" ;;
    ERROR) echo -e "${RED}[ERROR]${RESET} ${message}" ;;
  esac
}

# Example usage:
log DEBUG "This is a debug message."
log INFO "This is an info message."
log WARNING "This is a warning message."
log ERROR "This is an error message."
