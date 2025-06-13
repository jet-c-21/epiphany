#!/bin/bash
# script name: build-on-ubuntu-22.04.sh
# version: 0.0.1
set -e

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> color print >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Define the colors
declare -A COLORS=(
  ["red"]='\e[1;31m'
  ["green"]='\e[1;32m'
  ["blue"]='\e[1;34m'
  ["yellow"]='\e[1;33m'
  ["magenta"]='\e[1;35m'
  ["cyan"]='\e[1;36m'
  ["pink"]='\e[1;38;5;206m'
  ["white"]='\e[1;37m'
)
COLOR_RESET='\e[0m'

# Define the print function
cl_print() {
  local text=$1
  local color=$2

  # If the second argument is "dflt", print the text without color
  if [ "$color" == "dflt" ]; then
    echo -e "$text"
    return
  fi

  # If only one argument is provided, print in pink color
  if [ $# -eq 1 ]; then
    color="pink"
  fi

  # If the color is not defined, default to pink
  if [ -z "${COLORS[$color]}" ]; then
    color="pink"
  fi

  echo -e "${COLORS[$color]}${text}${COLOR_RESET}"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< color print <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ask user input sudo password >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
if [[ -z "${SUDO_PASSWORD}" ]]; then
  echo -n "[*INFO*] - Please enter your sudo password: "
  read -s user_input_password
  echo
  verify_password() {
    echo "$1" | sudo -S -v &>/dev/null
  }
  if verify_password "$user_input_password"; then
    export SUDO_PASSWORD="$user_input_password"
    echo "$SUDO_PASSWORD" | sudo -S -v &>/dev/null
  else
    echo "[*ERROR*] - Incorrect password." >&2
    exit 1
  fi
fi
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ask user input sudo password <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> use and unlock sudo >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
use_sudo() { # sudo experiment wrapper function
  : <<COMMENT
straight way:
  echo "$SUDO_PASSWORD" | sudo -S your command
example:
  echo "$SUDO_PASSWORD" | sudo -S apt-get update
COMMENT

  local cmd="echo ${SUDO_PASSWORD} | sudo -SE "
  for param in "$@"; do
    cmd+="${param} "
  done
  eval "${cmd}"
}

unlock_sudo() {
  local command="whoami"
  local result="$(use_sudo "$command")"
  echo "[*INFO*] - unlock $result privilege"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< use and unlock sudo <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

THIS_FILE_PATH="$(realpath "${BASH_SOURCE[0]}")"
THIS_FILE_PARENT_DIR="$(dirname "$THIS_FILE_PATH")"
PROJECT_DIR="$(dirname "$THIS_FILE_PARENT_DIR")"


install_dependencies() {
  cl_print "Installing dependencies..." "cyan"

  unlock_sudo
  sudo apt-get update
  sudo apt-get install -y \
    build-essential \
    meson \
    ninja-build \
    cmake \
    pkg-config \
    git \
    nettle-dev \
    libarchive-dev \
    libhandy-1-dev \
    libportal-gtk3-dev \
    appstream \
    itstool \
    gsettings-desktop-schemas-dev

  cl_print "Dependencies installed successfully!\n" "green"
}

config_before_build() {
  cl_print "Configuring build environment..." "cyan"

  # Create a fake pkg-config file for gsettings-desktop-schemas if it doesn't exist
  if [ ! -f /usr/lib/pkgconfig/gsettings-desktop-schemas.pc ]; then
    sudo tee /usr/lib/pkgconfig/gsettings-desktop-schemas.pc > /dev/null <<'EOF'
prefix=/usr
exec_prefix=${prefix}
datarootdir=${prefix}/share
schemasdir=${datarootdir}/glib-2.0/schemas

Name: gsettings-desktop-schemas
Description: GSettings desktop-wide schemas
Version: 42.0
EOF
    cl_print "Created fake gsettings-desktop-schemas.pc for pkg-config." "yellow"
  else
    cl_print "gsettings-desktop-schemas.pc already exists." "yellow"
  fi

  export CFLAGS="$CFLAGS -I/usr/include/gsettings-desktop-schemas"
  export CPPFLAGS="$CPPFLAGS -I/usr/include/gsettings-desktop-schemas"
  cl_print "Set CFLAGS and CPPFLAGS to include gsettings-desktop-schemas." "yellow"

  cl_print "Configuration complete.\n" "green"
}


build_on_ubuntu_22_04() {
  cl_print "[*INFO*] - Building on Ubuntu 22.04..." "blue"

  cd "$PROJECT_DIR"  # This points to /home/puff/my_home/side_projects
  cl_print "[*INFO*] - Current directory: $(pwd)"

  rm -rf build
  mkdir build && cd build

  install_dependencies
  config_before_build

  meson setup ..
  cl_print "[*INFO*] - finished meson setup" "green"

  ninja

  unlock_sudo
  sudo ninja install
}


# at the bottom of your all_in_one.sh
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    build_on_ubuntu_22_04 "$@"
fi




