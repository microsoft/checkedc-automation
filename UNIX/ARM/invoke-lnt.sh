set -ue
set -o pipefail
set -x

CURDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

CC=$CURDIR/clang-arm-x
CXX=${CC}++
CFLAGS="-fcheckedc-extension -static"
RUN=qemu-arm
TESTSUITE="$BUILD_SOURCESDIRECTORY/llvm-test-suite"

if [[ "$BMARK" = "yes" ]]; then
  CFLAGS+=" -I $TESTSUITE/include"

  "$LNT_SCRIPT" runtest test-suite \
    -v \
    --sandbox "$RESULTS_DIR" \
    --cc "$CC" \
    --cxx "$CXX" \
    --cflags "$CFLAGS" \
    --run-under "$RUN" \
    --test-suite "$TESTSUITE" \
    --submit "$LNT_DB_DIR" \
    --only-test "$ONLY_TEST" \
    --exec-multisample "$SAMPLES" \
    --run-order "$USER" \
    --cmake-define "CMAKE_STRIP:FILEPATH=llvm-strip" \
    --cmake-define "CMAKE_CXX_FLAGS:STRING=-static" \
    ${EXTRA_LNT_ARGS} \
    2>&1 | tee $RESULT_SUMMARY

else
  "$LNT_SCRIPT" runtest nt \
    -v \
    --sandbox "$RESULTS_DIR" \
    --cc "$CC" \
    --cxx "$CXX" \
    --cflags "$CFLAGS" \
    --qemu-user-mode "$RUN" \
    --test-suite "$TESTSUITE" \
    --output "$RESULT_DATA" \
    -j${BUILD_CPU_COUNT} \
    2>&1 | tee $RESULT_SUMMARY
fi

set +ue
set +o pipefail
