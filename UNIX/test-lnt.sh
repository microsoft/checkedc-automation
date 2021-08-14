#!/usr/bin/env bash

source ./config-vars.sh

echo "======================================================================"
echo "Running LNT validations for the Checked C compiler"
echo "======================================================================"

set -ue
set -o pipefail

if [ -z "$LNT" ]; then
  exit 0;
fi

export PATH=$LLVM_OBJ_DIR/bin:$PATH
if [ ! -e "`which clang`" ]; then
  echo "clang compiler not found"
  exit 1
fi

if [ -n "$LNT" ]; then
  rm -fr "$LNT_RESULTS_DIR"
  mkdir -p "$LNT_RESULTS_DIR"
  if [ ! -e "$LNT_SCRIPT" ]; then
    echo "LNT script is missing from $LNT_SCRIPT"
    exit 1
  fi
fi

for TEST_TARGET in $TEST_TARGET_ARCH; do
  export RESULTS_DIR=$LNT_RESULTS_DIR/$TEST_TARGET
  mkdir -p $RESULTS_DIR
  export RESULT_DATA="${RESULTS_DIR}/data.xml"
  export RESULT_SUMMARY="${RESULTS_DIR}/result.log"

  echo "======================================================================"
  echo "Testing LNT for $TEST_TARGET target"
  echo "======================================================================"
  $TEST_TARGET/invoke-lnt.sh

  if grep FAIL $RESULT_SUMMARY; then
    echo "LNT testing failed."
    exit 1
  else
    if [ $? -eq 2 ]; then
      echo "Grep of LNT result log unexpectedly failed."
      exit 1
    fi
  fi
done

set +ue
set +o pipefail
