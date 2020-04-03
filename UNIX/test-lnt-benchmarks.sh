#!/bin/bash

TOPDIR=$(dirname "$0")

# Note: You can set the following optional flags here:
# ONLY_TEST=SingleSource/Benchmarks/Dhrystone : Runs only the specified benchmarks.
# SAMPLES=n : Runs each benchmark SAMPLES no. of times. Default SAMPLES=1.

BENCHMARK=yes \
$TOPDIR/test-lnt.sh
