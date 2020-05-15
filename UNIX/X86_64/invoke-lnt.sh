set -ue
set -o pipefail
set -x

CC=clang
CXX=${CC}++
CFLAGS="-fcheckedc-extension"
TESTSUITE="$BUILD_SOURCESDIRECTORY/llvm-test-suite"

if [[ "$BMARK" = "yes" ]]; then
  CFLAGS+=" -I $TESTSUITE/include"

  "$LNT_SCRIPT" runtest test-suite \
    -v \
    --sandbox "$RESULTS_DIR" \
    --cc "$CC" \
    --cxx "$CXX" \
    --cflags "$CFLAGS" \
    --test-suite "$TESTSUITE" \
    --only-test "$ONLY_TEST" \
    --exec-multisample "$SAMPLES" \
    --run-order "$USER" \
    ${EXTRA_LNT_ARGS} \
    2>&1 | tee $RESULT_SUMMARY

else
  "$LNT_SCRIPT" runtest nt \
    -v \
    --sandbox "$RESULTS_DIR" \
    --cc "$CC" \
    --cxx "$CXX" \
    --cflags "$CFLAGS" \
    --test-suite "$TESTSUITE" \
    --output "$RESULT_DATA" \
    -j${BUILD_CPU_COUNT} \
    2>&1 | tee $RESULT_SUMMARY
fi

set +ue
set +o pipefail
