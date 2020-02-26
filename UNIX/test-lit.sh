#!/usr/bin/env bash

# For a description of the config variables set/used here,
# see automation/Windows/build-and-test.bat.

source ./config-vars.sh

echo "======================================================================"
echo "Running unit tests using lit for the Checked C compiler"
echo "======================================================================"

set -ue
set -o pipefail

export PATH=$LLVM_OBJ_DIR/bin:$PATH
if [ ! -e "`which clang`" ]; then
  echo "clang compiler not found"
  exit 1
fi

cd $LLVM_OBJ_DIR

echo ninja -v -j${BUILD_CPU_COUNT} check-checkedc
ninja -v -j${BUILD_CPU_COUNT} check-checkedc

if [ "$TEST_SUITE" == "CheckedC_LLVM" ]; then
  echo ninja -v -j${BUILD_CPU_COUNT} check-all
  ninja -v -j${BUILD_CPU_COUNT} check-all
else
  echo ninja -v -j${BUILD_CPU_COUNT} check-clang
  ninja -v -j${BUILD_CPU_COUNT} check-clang
fi

set +ue
set +o pipefail
