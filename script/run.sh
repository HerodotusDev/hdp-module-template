#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_request.json> <path_to_compiled_contract.json>"
    echo "Example: $0 ./request.json ./compiled_contract.json"
    exit 1
fi

REQUEST_PATH="$1"
COMPILED_CONTRACT_PATH="$2"

# Check if files exist
if [ ! -f "$REQUEST_PATH" ]; then
    echo "Error: Request file not found at $REQUEST_PATH"
    exit 1
fi

if [ ! -f "$COMPILED_CONTRACT_PATH" ]; then
    echo "Error: Compiled contract file not found at $COMPILED_CONTRACT_PATH"
    exit 1
fi

# Load environment variables from .env file
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create one with the following fields:"
    echo "PROVIDER_URL_ETHEREUM_SEPOLIA=<ethereum_sepolia_rpc_url>"
    echo "PROVIDER_URL_STARKNET_SEPOLIA=<starknet_sepolia_rpc_url>"
    exit 1
fi

source .env

# Run docker command
docker run \
  -v $(pwd)/"$REQUEST_PATH":/hdp-runner/request.json \
  -v $(pwd)/"$COMPILED_CONTRACT_PATH":/hdp-runner/local_contract.json \
  -e PROVIDER_URL_ETHEREUM_SEPOLIA="$PROVIDER_URL_ETHEREUM_SEPOLIA" \
  -e PROVIDER_URL_STARKNET_SEPOLIA="$PROVIDER_URL_STARKNET_SEPOLIA" \
  -e RPC_URL="$PROVIDER_URL_ETHEREUM_SEPOLIA" \
  dataprocessor/hdp-runner:latest