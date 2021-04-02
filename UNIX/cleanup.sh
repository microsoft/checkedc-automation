#!/usr/bin/env bash

source ./config-vars.sh

echo "======================================================================"
echo "Cleaning Checked C src and build dirs"
echo "======================================================================"

set -ue
set -o pipefail

if [ "$CLEAN_SRC_BUILD_DIR" == "No" ]; then
  echo "Clean.Src.Build.Dir is set to No. Nothing to clean."

elif [ "$CLEAN_SRC_BUILD_DIR"=="Yes" ]; then
  echo "Clean.Src.Build.Dir is set to Yes. Trying to clean dirs."

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
