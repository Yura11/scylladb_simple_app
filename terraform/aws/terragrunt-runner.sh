#!/bin/bash

# Check for required input
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <command> <environment> <module>"
  echo "Example: $0 apply dev vpc"
  exit 1
fi

# Assign inputs
COMMAND=$1
ENVIRONMENT=$2
MODULE=$3

# Base directory for Terragrunt configurations
TERRAGRUNT_DIR="./environments"

# Construct the path
TARGET_DIR="${TERRAGRUNT_DIR}/${ENVIRONMENT}/${MODULE}"

# Check if the target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Directory $TARGET_DIR does not exist."
  exit 1
fi

# Check if terragrunt.hcl exists in the target directory
if [[ ! -f "${TARGET_DIR}/terragrunt.hcl" ]]; then
  echo "Error: terragrunt.hcl not found in ${TARGET_DIR}."
  exit 1
fi

# Navigate to the target directory and run the command
echo ">>> Running 'terragrunt ${COMMAND}' in ${TARGET_DIR}..."
cd "$TARGET_DIR"

terragrunt "${COMMAND}"
RESULT=$?

# Check command result
if [[ $RESULT -ne 0 ]]; then
  echo "Error: 'terragrunt ${COMMAND}' failed in ${TARGET_DIR}."
  exit $RESULT
else
  echo ">>> 'terragrunt ${COMMAND}' completed successfully in ${TARGET_DIR}."
fi
