#!/usr/bin/env bash

set -e

unameOut=$(uname -a)
case "${unameOut}" in
*Microsoft*) OS="WSL" ;; #wls must be first since it will have Linux in the name too
*microsoft*) OS="WSL2" ;;
Linux*) OS="Linux" ;;
Darwin*) OS="Mac" ;;
CYGWIN*) OS="Cygwin" ;;
MINGW*) OS="Windows" ;;
*Msys) OS="Windows" ;;
*) OS="UNKNOWN:${unameOut}" ;;
esac

if [[ ${OS} == "Mac" ]] && sysctl -n machdep.cpu.brand_string | grep -q 'Apple M1'; then
    #Check if its an M1. This check should work even if the current processes is running under x86 emulation.
    OS="MacM1"
fi

case $OS in
MacM1)
    CONFIG=".profiles/mac/dotbot-mac.yml"
    ;;
WSL2)
    CONFIG=".profiles/wsl/dotbot-wsl.yml"
    ;;
Windows)
    echo "To run this script in windows, use the install.ps1 script instead"
    exit
    ;;
*)
    echo "No configuration found for ${OS}!"
    exit 1
    ;;
esac

echo "Running installer for $OS"

DOTBOT_DIR="dotbot"
DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${BASEDIR}"
git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
git submodule update --init --recursive "${DOTBOT_DIR}"

"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"
