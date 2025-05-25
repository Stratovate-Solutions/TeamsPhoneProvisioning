#!/usr/bin/env bash
# Setup script to install PowerShell and required modules
# Use on Ubuntu-based environments
set -euo pipefail

# Install PowerShell if not already installed
if ! command -v pwsh >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y wget apt-transport-https software-properties-common
  wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt-get update
  sudo apt-get install -y powershell
fi

# Install MicrosoftTeams PowerShell module
pwsh -Command "Install-Module -Name MicrosoftTeams -Force -Scope CurrentUser"
