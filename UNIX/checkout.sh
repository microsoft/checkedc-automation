#!/usr/bin/env bash

source ./config-vars.sh

echo "======================================================================"
echo "Checking out checkedc and test-suite sources"
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

cd "$BUILD_SOURCESDIRECTORY"
CURDIR=$PWD

# Check out Checked C Tests
clone_or_update $CURDIR llvm/projects/checkedc-wrapper/checkedc https://github.com/Microsoft/checkedc "$CHECKEDC_BRANCH"

# Check out LLVM test suite
if [ -n "$LNT" ]; then
  clone_or_update $CURDIR llvm-test-suite https://github.com/Microsoft/checkedc-llvm-test-suite "$LLVM_TEST_SUITE_BRANCH"
fi

set +ue
set +o pipefail
