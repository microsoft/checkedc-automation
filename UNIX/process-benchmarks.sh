#!/bin/bash

BENCHMARK=yes
source ./config-vars.sh

for TEST_TARGET in $TEST_TARGET_ARCH; do
  echo "======================================================================"
  echo "Processing benchmark results for target $TEST_TARGET"
  echo "======================================================================"

  LOGFILE=$LNT_RESULTS_DIR/$TEST_TARGET/result.log
  if [[ ! -f "$LOGFILE" ]]; then
    echo "Benchmark results log $LOGFILE not found. Exiting ..."
    exit 1
  fi

  export STORAGE_ACCOUNT_NAME=$(Storage.Account.Name)
  export STORAGE_ACCOUNT_KEY=$(Storage.Account.Key)

  python extract_benchmark_data.py --logfile $LOGFILE --output-type text --store-to-db
done
