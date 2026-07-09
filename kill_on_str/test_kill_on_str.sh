#!/usr/bin/env bash
# test_kill_on_string.sh
#
# Test suite for kill_on_string.c (the filter-mode version: reads stdin,
# forwards to stdout, kills its process group on a pattern match).
#
# Usage:
#   ./test_kill_on_string.sh path/to/kill_on_string.c
#
# Builds the binary fresh, runs each test in its own process group
# (via setsid) so a triggered kill(0, SIGTERM) only affects that test
# and not this test runner, and reports PASS/FAIL for each case.

set -u

SRC="${1:-kill_on_string.c}"
if [ ! -f "$SRC" ]; then
    echo "usage: $0 path/to/kill_on_string.c"
    exit 2
fi

WORKDIR=$(mktemp -d)
BIN="$WORKDIR/kill_on_string"
trap 'rm -rf "$WORKDIR"' EXIT

echo "Building $SRC ..."
if ! gcc -Wall -Wextra -O2 -o "$BIN" "$SRC"; then
    echo "BUILD FAILED"
    exit 1
fi
echo "Build OK: $BIN"
echo

PASS=0
FAIL=0

# fail(msg) - record a failure with a message
fail() {
    echo "  FAIL: $1"
    FAIL=$((FAIL+1))
}
pass() {
    echo "  PASS"
    PASS=$((PASS+1))
}

# ---------------------------------------------------------------------
# Test 1: basic match - forwards everything up to and including the
# matching chunk, then kills the pipeline.
# ---------------------------------------------------------------------
test_basic_match() {
    echo "[1] basic match forwards data then kills"
    local out="$WORKDIR/t1.out"
    : > "$out"
    setsid bash -c "printf 'line1\nline2\nERROR: bad\nline4\n' | '$BIN' 'ERROR:' > '$out'" \
        2>"$WORKDIR/t1.err"
    sleep 0.2
    local expected=$'line1\nline2\nERROR: bad\nline4'
    local got
    got=$(cat "$out")
    if [ "$got" = "$expected" ]; then
        pass
    else
        fail "expected [$expected] got [$got]"
    fi
}

# ---------------------------------------------------------------------
# Test 2: no match at all - everything forwarded, exits 0.
# ---------------------------------------------------------------------
test_no_match() {
    echo "[2] no match: full passthrough, exit 0"
    local out="$WORKDIR/t2.out"
    printf 'line1\nline2\nline3\n' | "$BIN" "NEVERMATCH" > "$out"
    local status=$?
    local expected=$'line1\nline2\nline3'
    local got
    got=$(cat "$out")
    if [ "$got" = "$expected" ] && [ "$status" -eq 0 ]; then
        pass
    else
        fail "expected [$expected] exit0, got [$got] exit=$status"
    fi
}

# ---------------------------------------------------------------------
# Test 3: pattern split across two separate read() calls must still
# be detected (boundary matching).
# ---------------------------------------------------------------------
test_split_match() {
    echo "[3] pattern split across two reads is still caught"
    local out="$WORKDIR/t3.out"
    : > "$out"
    cat > "$WORKDIR/feed3.py" <<'PY'
import sys, time
sys.stdout.write("A" * 200 + "ERR")   # ends mid-pattern
sys.stdout.flush()
time.sleep(0.3)
sys.stdout.write("OR: real problem\nmore text\n")
sys.stdout.flush()
PY
    setsid bash -c "python3 '$WORKDIR/feed3.py' | '$BIN' 'ERROR:' > '$out'" \
        2>"$WORKDIR/t3.err"
    sleep 0.5
    if grep -q "ERROR: real problem" "$out" && grep -q "matched" "$WORKDIR/t3.err"; then
        pass
    else
        fail "expected match to be detected; stderr=[$(cat "$WORKDIR/t3.err")] out=[$(cat "$out")]"
    fi
}

# ---------------------------------------------------------------------
# Test 4: false positive regression. A long first read followed by a
# short second read must NOT let stale bytes from the first read
# combine with the second read to form a phantom match. Also exercises
# a needle whose "poisoned prefix" (needle with last byte incremented)
# would coincide with real stream data if that trick were used.
# ---------------------------------------------------------------------
test_no_false_positive_on_short_second_read() {
    echo "[4] no false positive: short read after long read, needle=BBA"
    local out="$WORKDIR/t4.out"
    : > "$out"
    cat > "$WORKDIR/feed4.py" <<'PY'
import sys, time
sys.stdout.write("A" * 200 + "\n")
sys.stdout.flush()
time.sleep(0.3)
sys.stdout.write("BB")          # no trailing newline - short 2nd read
sys.stdout.flush()
time.sleep(0.3)
sys.stdout.write("\nCCC\n")
sys.stdout.flush()
PY
    # The live stream is: 200 A's, newline, "BB", newline, "CCC", newline.
    # It never contains the substring "BBA" anywhere.
    setsid bash -c "python3 '$WORKDIR/feed4.py' | '$BIN' 'BBA' > '$out'" \
        2>"$WORKDIR/t4.err"
    sleep 0.7
    local expected_bytes=208   # 201 + 2 + 1 + 3 + 1
    local got_bytes
    got_bytes=$(wc -c < "$out" | tr -d ' ')
    if [ "$got_bytes" -eq "$expected_bytes" ] && ! grep -q "matched" "$WORKDIR/t4.err"; then
        pass
    else
        fail "expected full $expected_bytes-byte passthrough with no match; got $got_bytes bytes, stderr=[$(cat "$WORKDIR/t4.err")]"
    fi
}

# ---------------------------------------------------------------------
# Test 5: match occurs at the very start of the very first chunk.
# ---------------------------------------------------------------------
test_match_at_start() {
    echo "[5] match at the very start of the stream"
    local out="$WORKDIR/t5.out"
    : > "$out"
    setsid bash -c "printf 'ERROR: right away' | '$BIN' 'ERROR:' > '$out'" \
        2>"$WORKDIR/t5.err"
    sleep 0.2
    if grep -q "ERROR: right away" "$out" && grep -q "matched" "$WORKDIR/t5.err"; then
        pass
    else
        fail "expected immediate match; out=[$(cat "$out")] stderr=[$(cat "$WORKDIR/t5.err")]"
    fi
}

# ---------------------------------------------------------------------
# Test 6: single-character needle (edge case for needle_len - 1 == 0).
# ---------------------------------------------------------------------
test_single_char_needle() {
    echo "[6] single-character needle"
    local out="$WORKDIR/t6.out"
    : > "$out"
    setsid bash -c "printf 'hello X world' | '$BIN' 'X' > '$out'" \
        2>"$WORKDIR/t6.err"
    sleep 0.2
    if grep -q "hello X world" "$out" && grep -q "matched" "$WORKDIR/t6.err"; then
        pass
    else
        fail "expected match on single-char needle; out=[$(cat "$out")] stderr=[$(cat "$WORKDIR/t6.err")]"
    fi
}

# ---------------------------------------------------------------------
# Test 7: multi-chunk clean run (several small delayed writes, no
# match anywhere) - everything should be forwarded, exit 0.
# ---------------------------------------------------------------------
test_multi_chunk_clean() {
    echo "[7] multiple clean chunks, no match, exit 0"
    local out="$WORKDIR/t7.out"
    : > "$out"
    python3 -c "
import sys, time
for i in range(5):
    sys.stdout.write('chunk %d clean data no bad words here\n' % i)
    sys.stdout.flush()
    time.sleep(0.05)
" | "$BIN" "NEVERMATCH" > "$out"
    local status=$?
    local lines
    lines=$(wc -l < "$out" | tr -d ' ')
    if [ "$lines" -eq 5 ] && [ "$status" -eq 0 ]; then
        pass
    else
        fail "expected 5 lines forwarded, exit 0; got $lines lines, exit=$status"
    fi
}

# ---------------------------------------------------------------------
# Test 8: empty pattern argument should be rejected.
# ---------------------------------------------------------------------
test_empty_pattern_rejected() {
    echo "[8] empty pattern is rejected"
    echo "x" | "$BIN" "" > /dev/null 2>"$WORKDIR/t8.err"
    local status=$?
    if [ "$status" -eq 2 ]; then
        pass
    else
        fail "expected exit 2 for empty pattern, got $status"
    fi
}

test_basic_match
test_no_match
test_split_match
test_no_false_positive_on_short_second_read
test_match_at_start
test_single_char_needle
test_multi_chunk_clean
test_empty_pattern_rejected

echo
echo "===================="
echo "PASS: $PASS  FAIL: $FAIL"
echo "===================="
[ "$FAIL" -eq 0 ]
