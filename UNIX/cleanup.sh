#!/usr/bin/env bash

# For a description of the config variables set/used here,
# see automation/Windows/build-and-test.bat.

source ./config-vars.sh

echo "======================================================================"
echo "Cleaning Checked C src and build dirs"
echo "======================================================================"

set -ue
set -o pipefail

if [ "$CLEAN_BUILD_SRC_DIR" == "No" ]; then
  echo "Clean.Build.Src.Dir is set to No. Nothing to clean."

elif [ "$CLEAN_BUILD_SRC_DIR"=="Yes" ]; then
  echo "Clean.Build.Src.Dir is set to Yes. Trying to clean dirs."

  if [ -d "$BUILD_SOURCESDIRECTORY" ]; then
    echo "Cleaning src dir: $BUILD_SOURCESDIRECTORY"
    rm -rf "$BUILD_SOURCESDIRECTORY"
  else
    echo "Src dir $BUILD_SOURCESDIRECTORY not found"
  fi

  if [ -d "$LLVM_OBJ_DIR" ]; then
    echo "Cleaning build dir: $LLVM_OBJ_DIR"
    rm -rf "$LLVM_OBJ_DIR"
  else
    echo "Build dir $LLVM_OBJ_DIR not found"
  fi
fi

set +ue
set +o pipefail
