#!/usr/bin/env bash
# $1 is the user link

script_dir=$(dirname "$0")
source "$script_dir/lib/common_functions.sh"

# funtions

# get the version of the python file
function get_version {
    local version=$(dirname "$1")
    version=$(basename "$version")
    version=${version%.*}
    echo "$version"
}

# checks if the file extension is .tgz
function check_tgz {
    if [[ $1 != *.tgz ]]; then
        error_message "file provided does not end with .tgz"
    fi
}

# downloads the file from the url
# and checks if it was successful
function get {
    wget --timeout=600 "$1" --no-check-certificate
    if [ $? -ne 0 ]; then
        error_message "failed to download file"
    fi
}

# installs the python file
function python_install {
    sudo apt-get update
    sudo apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev
    tar -xf $1
    python_folder=$(basename "$1" .tgz)
    $python_folder/configure --enable-optimizations
    make
    make altinstall
    rm -r "$2"
}

# variables
original_user=$(get_username)
base_folder="$(getent passwd $original_user | cut -d: -f6)/python_versions"
filename=$(basename "$1")

# main script

# confirms if running with sudo/root
root_confirm

# checks if file is a tgz
check_tgz "$1"

# gets the version of the python file
# is already installed
version=$(get_version "$1")
verify_version "$version"

# creates the base folder
# if the folder already exists, first delete it.
if check_if_exists "$base_folder"; then
    rm -rf "$base_folder"
fi
make_dir "$base_folder"

# downloads the file
get $1

# installs the file
# and removes the python folder/files
python_install "$filename" "$base_folder"

