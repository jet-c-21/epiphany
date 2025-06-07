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
#use_sudo() { # sudo experiment wrapper function
#  : <<COMMENT
#straight way:
#  echo "$SUDO_PASSWORD" | sudo -S your command
#example:
#  echo "$SUDO_PASSWORD" | sudo -S apt-get update
#COMMENT
#
#  local cmd="echo ${SUDO_PASSWORD} | sudo -SE "
#  for param in "$@"; do
#    cmd+="${param} "
#  done
#  eval "${cmd}"
#}

unlock_sudo() {
  local command="whoami"
  local result="$(use_sudo "$command")"
  echo "[*INFO*] - unlock $result privilege"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< use and unlock sudo <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

THIS_FILE_PATH="$(realpath "${BASH_SOURCE[0]}")"
THIS_FILE_PARENT_DIR="$(dirname "$THIS_FILE_PATH")"
PROJECT_DIR="$(dirname "$THIS_FILE_PARENT_DIR")"

install_gcr() {
  cl_print "Installing GCR 4.x from source..." "cyan"

  # Ensure sudo is unlocked
  unlock_sudo

  # Check if gcr-4.pc already exists
  if pkg-config --exists gcr-4; then
    cl_print "GCR 4 already installed, skipping build." "green"
    return
  fi

  # Install build dependencies for GCR 4
  sudo apt-get install -y \
    libglib2.0-dev \
    libp11-kit-dev \
    libgdk-pixbuf2.0-dev \
    libgtk-3-dev \
    gtk-doc-tools \
    gobject-introspection \
    libgcrypt20-dev \
    libgirepository1.0-dev \
    libglib2.0-doc \
    libglib2.0-dev-bin \
    intltool

  # Download and build GCR 4
  TMPDIR="$(mktemp -d)"
  git clone --depth 1 --branch 4.1.0 https://gitlab.gnome.org/GNOME/gcr.git "$TMPDIR/gcr"
  cd "$TMPDIR/gcr"
  mkdir build && cd build
  meson setup .. -Dgtk_doc=false
  ninja
  sudo ninja install
  cd
  rm -rf "$TMPDIR"
  cl_print "GCR 4 installation completed." "green"
}


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
    git
}

build_on_ubuntu_22_04() {
  cl_print $PROJECT_DIR

  rm -rf build
  mkdir build && cd build
  install_dependencies
  meson setup ..
}

# at the bottom of your all_in_one.sh
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    build_on_ubuntu_22_04 "$@"
fi
