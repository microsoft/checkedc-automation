#!/bin/bash

BENCHMARK=yes
source ./config-vars.sh

for TEST_TARGET in $TEST_TARGET_ARCH; do
  echo "\n"
  echo "======================================================================"
  echo "Processing benchmark results for target $TEST_TARGET"
  echo "======================================================================"

  LOGFILE=$LNT_RESULTS_DIR/$TEST_TARGET/result.log
  if [[ ! -f "$LOGFILE" ]]; then
    echo "Benchmark results log $LOGFILE not found. Exiting ..."
    exit 1
  fi
  export TEST_TARGET

  # Extract benchmark results from the LNT log file, pretty print the results
  # to stdout and post them the Azure Table Storage.
  python extract_benchmark_data.py --logfile $LOGFILE --pretty-print --store-to-db
done
