#!/bin/bash -x

CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd $CURDIR

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

  echo $STORAGEACCOUNTNAME
  python extract_benchmark_data.py --logfile $LOGFILE --output-type text --store-to-db
done
