#!/usr/bin/env bash


source ./config-vars.sh

echo "======================================================================"
echo "Running clangd tests using lit for the Checked C compiler"
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

echo ninja -v -j${BUILD_CPU_COUNT} check-clangd
ninja -v -j${BUILD_CPU_COUNT} check-clangd

set +ue
set +o pipefail
