#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error
set -o pipefail  # Prevent errors in a pipeline from being masked

# Load .env variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo ".env variables loaded successfully."
else
    echo "Error: .env file not found. Please create a .env file with the required variables."
    exit 1
fi

# Function to clone the program registry
clone_registry() {
    echo "Cloning program registry..."
    temp_dir=$(mktemp -d)

    git clone https://github.com/petscheit/cairo-program-registry-new.git "$temp_dir/cairo-program-registry" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        rm -rf cairo-programs
        mv "$temp_dir/cairo-program-registry" cairo-programs
        rm -rf "$temp_dir"
        echo "Programs directory created/updated successfully."
    else
        echo "Failed to clone registry."
        rm -rf "$temp_dir"
        exit 1
    fi
}

# Function to check if a program directory exists
check_program_dir() {
    local hash=$1
    if [ ! -d "cairo-programs/$hash" ]; then
        echo "Required program directory for hash $hash not found."
        return 1
    fi
    return 0
}

# Check if cairo-programs directory exists and contains required directories
needs_clone=false

if [ ! -d "cairo-programs" ]; then
    echo "cairo-programs directory does not exist."
    needs_clone=true
else
    if ! check_program_dir "$HDP_PROGRAM_HASH" || ! check_program_dir "$DRY_RUN_PROGRAM_HASH"; then
        echo "One or more required program directories are missing."
        needs_clone=true
    fi
fi

if [ "$needs_clone" = true ]; then
    echo "Cloning/updating registry..."
    clone_registry
else
    echo "All required program directories are present."
fi

# Final check for both program directories
if ! check_program_dir "$HDP_PROGRAM_HASH" || ! check_program_dir "$DRY_RUN_PROGRAM_HASH"; then
    echo "Error: Required program directories still not available after clone/update."
    exit 1
else
    echo "Required program directories found."
fi

# Create build directory if it doesn't exist
BUILD_DIR="build"
mkdir -p "$BUILD_DIR"

# Function to copy program.json to build folder
copy_program_json() {
    local hash=$1
    local source_file="cairo-programs/$hash/program.json"
    local dest_file="$BUILD_DIR/${hash}.json"

    if [ -f "$source_file" ]; then
        cp "$source_file" "$dest_file"
        echo "Copied program.json for hash $hash to $dest_file."
    else
        echo "Error: $source_file does not exist."
        exit 1
    fi
}

# Copy program.json files for both hashes
copy_program_json "$HDP_PROGRAM_HASH"
copy_program_json "$DRY_RUN_PROGRAM_HASH"

echo "All program.json files have been positioned in the $BUILD_DIR folder successfully."
