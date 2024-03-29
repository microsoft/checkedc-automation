#!/usr/bin/env bash

# For a description of the config variables set/used here,
# see automation/Windows/build-and-test.bat.

source ./config-vars.sh

echo "======================================================================"
echo "Configuring and building the Checked C compiler"
echo "======================================================================"

set -ue
set -o pipefail

if [ "${CHECKEDC_CONFIG_STATUS}" == "error" ]; then
  exit 1;
fi

CMAKE_ADDITIONAL_OPTIONS=""
if [[ ("$LNT" != "" || "$BUILD_PACKAGE" == "Yes") &&
      ("$BUILDCONFIGURATION" == "Release" || "$BUILDCONFIGURATION" == "ReleaseWithDebInfo") ]]; then
  CMAKE_ADDITIONAL_OPTIONS="-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_ENABLE_ASSERTIONS=ON"
fi

if [[ "$CLANGD" == "Yes" ]]; then
  ENABLEPROJECTS="clang;clang-tools-extra"
else
  ENABLEPROJECTS="clang"
fi

mkdir -p "$LLVM_OBJ_DIR"
cd "$LLVM_OBJ_DIR"

echo "======================================================================"
echo "Running the configure step"
echo "======================================================================"

echo cmake -G Ninja \
  ${CMAKE_ADDITIONAL_OPTIONS} \
  -DLLVM_ENABLE_PROJECTS="$ENABLEPROJECTS" \
  -DCMAKE_BUILD_TYPE="$BUILDCONFIGURATION" \
  -DCHECKEDC_ARM_RUNUNDER="qemu-arm" \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_LIT_ARGS=-v \
  "$BUILD_SOURCESDIRECTORY/llvm"

cmake -G Ninja \
  ${CMAKE_ADDITIONAL_OPTIONS} \
  -DLLVM_ENABLE_PROJECTS="$ENABLEPROJECTS" \
  -DCMAKE_BUILD_TYPE="$BUILDCONFIGURATION" \
  -DCHECKEDC_ARM_RUNUNDER="qemu-arm" \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_LIT_ARGS=-v \
  "$BUILD_SOURCESDIRECTORY/llvm"

if [[ $? -ne 0 ]]; then
  echo "Configure failed. Exiting."
  exit 1
fi

echo "======================================================================"
echo "Running the build step"
echo "======================================================================"
if [[ "$BUILD_PACKAGE" == "Yes" ]]; then
  echo ninja -j${BUILD_CPU_COUNT}
  ninja -j${BUILD_CPU_COUNT}
elif [[ "$TEST_SUITE" == "CheckedC_LLVM" ]]; then
  echo ninja -j${BUILD_CPU_COUNT}
  ninja -j${BUILD_CPU_COUNT}
elif [[ "$CLANGD" == "Yes" ]]; then
  echo ninja -j${BUILD_CPU_COUNT} clang llvm-size llvm-strip clangd
  ninja -j${BUILD_CPU_COUNT} clang llvm-size llvm-strip clangd
else
  echo ninja -j${BUILD_CPU_COUNT} clang llvm-size llvm-strip
  ninja -j${BUILD_CPU_COUNT} clang llvm-size llvm-strip
fi

set +x
set +ue
set +o pipefail
