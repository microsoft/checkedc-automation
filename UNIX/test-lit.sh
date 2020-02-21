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

cd ${LLVM_OBJ_DIR}

echo "======================================================================"
echo "Running ninja -v check-checkedc"
echo "======================================================================"
ninja -v check-checkedc

if [ "${TEST_SUITE}" == "CheckedC_LLVM" ]; then
  echo "======================================================================"
  echo "Running ninja -v check-all"
  echo "======================================================================"
  ninja -v check-all
else
  echo "======================================================================"
  echo "Running ninja -v check-clang"
  echo "======================================================================"
  ninja -v check-clang
fi

set +ue
set +o pipefail
