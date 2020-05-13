#!/bin/bash

BENCHMARK=yes
source ./config-vars.sh

for TEST_TARGET in $TEST_TARGET_ARCH; do
  echo "======================================================================"
  echo "Processing benchmarks for target $TEST_TARGET"
  echo "======================================================================"

  LOGFILE=$LNT_RESULTS_DIR/$TEST_TARGET/result.log
  if [[ ! -f "$LOGFILE" ]]; then
    echo "Benchmark results log $LOGFILE not found. Exiting ..."
    exit 1
  fi

  python extract_benchmark_data.py --logfile $LOGFILE --output-type text --store-to-db
done
