#!/bin/bash
set -euo pipefail  # Add strict mode for better error handling

# Define constants at the top
readonly REQUIRED_ENV_VARS=("PROVIDER_URL_ETHEREUM_SEPOLIA")
readonly OUTPUT_FILES=("cairo.pie" "input.json" "batch.json")

# Function to check required environment variables
check_env_vars() {
    local missing_vars=0
    for var in "${REQUIRED_ENV_VARS[@]}"; do
        if [ -z "${!var-}" ]; then
            echo "Error: $var is required in .env file"
            missing_vars=1
        fi
    done
    return $missing_vars
}

# Check if required arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <path_to_request.json> <path_to_compiled_contract.json> [output_directory]"
    echo "Example: $0 ./request.json ./compiled_contract.json ./my_output"
    exit 1
fi

REQUEST_PATH="$1"
COMPILED_CONTRACT_PATH="$2"
OUTPUT_DIR="${3:-}"  # Make OUTPUT_DIR optional by using parameter expansion with default empty string

# Replace file checking with loop
for file in "$REQUEST_PATH" "$COMPILED_CONTRACT_PATH"; do
    if [ ! -f "$file" ]; then
        echo "Error: File not found at $file"
        exit 1
    fi
done

# Load environment variables from .env file
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create one with the following fields:"
    printf "%s\n" "${REQUIRED_ENV_VARS[@]/#/- }"
    exit 1
fi

source .env
check_env_vars || exit 1

# Build docker command using an array for better handling of spaces and special characters
docker_args=(
    "run"
    "-v" "$(pwd)/$REQUEST_PATH:/hdp-runner/request.json"
    "-v" "$(pwd)/$COMPILED_CONTRACT_PATH:/hdp-runner/local_contract.json"
    "-e" "PROVIDER_URL_ETHEREUM_SEPOLIA=$PROVIDER_URL_ETHEREUM_SEPOLIA"
    "-e" "RPC_URL=$PROVIDER_URL_ETHEREUM_SEPOLIA"
)

# Add Starknet environment variable if it exists
if [ ! -z "$PROVIDER_URL_STARKNET_SEPOLIA" ]; then
    docker_args+=(
        "-e" "PROVIDER_URL_STARKNET_SEPOLIA=$PROVIDER_URL_STARKNET_SEPOLIA"
    )
fi

# Handle output directory (only if provided)
if [ -n "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    
    # Create output files
    for file in "${OUTPUT_FILES[@]}"; do
        touch "$OUTPUT_DIR/$file"
        docker_args+=(
            "-v" "$(pwd)/$OUTPUT_DIR/$file:/hdp-runner/$file"
        )
    done
fi

docker_args+=("dataprocessor/hdp-runner:latest")

# Execute docker command
docker "${docker_args[@]}"

# Show output directory message only if it was specified
if [ ! -z "$OUTPUT_DIR" ]; then
    echo "Output files are saved in the '$OUTPUT_DIR' directory."
fi
