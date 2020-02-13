#!/usr/bin/env bash

# For a description of the config variables set/used here,
# see automation/Windows/build-and-test.bat.

source ./config-vars.sh

echo "======================================================================"
echo "Checking out checkedc-clang sources"
echo "======================================================================"

set -ue
set -o pipefail

function clone_or_update {
  local curdir=$1
  local srcdir=$2
  local url=$3
  local branch=$4

  echo "======================================================================"
  echo "SRCDIR: $curdir/$srcdir"
  echo "URL: $url"
  echo "BRANCH: $branch"
  echo "======================================================================"

set -x
  cd $curdir

  if [ ! -d $srcdir/.git ]; then
    echo "Cloning sources"
    git clone $url $srcdir
  else
    echo "Updating sources"
    cd $curdir/$srcdir &&
    git fetch origin
  fi

  echo "Checking out branch"
  cd $curdir/$srcdir &&
  git checkout -f $branch &&
  git pull -f origin $branch

set +x
}

# Make build dir.
mkdir -p "$LLVM_OBJ_DIR"

if [ -n "$LNT" ]; then
  rm -fr "$LNT_RESULTS_DIR"
  mkdir -p "$LNT_RESULTS_DIR"
  if [ ! -e "$LNT_SCRIPT" ]; then
    echo "LNT script is missing from $LNT_SCRIPT"
    exit 1
  fi
fi
cd "$BUILD_SOURCESDIRECTORY"

CURDIR=$PWD

# Check out Clang
clone_or_update $CURDIR checkedc-clang https://github.com/Microsoft/checkedc-clang "$CLANG_BRANCH"

# Check out Checked C Tests
clone_or_update $CURDIR checkedc-clang/llvm/projects/checkedc-wrapper/checkedc https://github.com/Microsoft/checkedc "$CHECKEDC_BRANCH"

# Check out LLVM test suite
if [ -n "$LNT" ]; then
  clone_or_update $CURDIR llvm-test-suite https://github.com/Microsoft/checkedc-llvm-test-suite "$LLVM_TEST_SUITE_BRANCH"
fi

set +ue
set +o pipefail
