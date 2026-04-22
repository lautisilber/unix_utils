#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* -------------------------------------------------------------------------
 * Minimal test framework
 * --------------------------------------------------------------------- */

static int tests_run    = 0;
static int tests_passed = 0;

#define CHECK(desc, expr)                                               \
    do {                                                                \
        tests_run++;                                                    \
        if (expr) {                                                     \
            printf("  PASS  %s\n", desc);                              \
            tests_passed++;                                             \
        } else {                                                        \
            printf("  FAIL  %s  (line %d)\n", desc, __LINE__);         \
        }                                                               \
    } while (0)

/* -------------------------------------------------------------------------
 * Helpers
 * --------------------------------------------------------------------- */

#define TS_BIN "./ts"

/* Run ts with input passed as a positional argument, plus any extra args.
   Returns heap-allocated stdout output. Caller must free(). */
static char *run_ts(const char *input, const char *args) {
    char cmd[512];
    snprintf(cmd, sizeof(cmd), "%s %s '%s'", TS_BIN, args, input);

    FILE *f = popen(cmd, "r");
    if (!f) return NULL;

    size_t cap = 4096, len = 0;
    char *buf = malloc(cap);
    if (!buf) { pclose(f); return NULL; }

    int c;
    while ((c = fgetc(f)) != EOF) {
        if (len + 1 >= cap) {
            cap *= 2;
            char *tmp = realloc(buf, cap);
            if (!tmp) { free(buf); pclose(f); return NULL; }
            buf = tmp;
        }
        buf[len++] = (char)c;
    }
    buf[len] = '\0';
    pclose(f);
    return buf;
}

/* Count non-overlapping occurrences of needle in haystack */
static int count_occurrences(const char *haystack, const char *needle) {
    int count = 0;
    size_t nlen = strlen(needle);
    const char *p = haystack;
    while ((p = strstr(p, needle)) != NULL) {
        count++;
        p += nlen;
    }
    return count;
}

/* Check that a string matches the timestamp format [YYYY/mm/dd HH:MM:SS] */
static int looks_like_timestamp(const char *s) {
    if (strlen(s) < 22) return 0;
    return s[0]  == '['
        && s[5]  == '/'
        && s[8]  == '/'
        && s[11] == ' '
        && s[14] == ':'
        && s[17] == ':'
        && s[20] == ']';
}

/* -------------------------------------------------------------------------
 * Correctness tests
 * --------------------------------------------------------------------- */

static void test_correctness(void) {
    printf("=== Correctness ===\n");

    char *out;

    /* Single line: should produce exactly one timestamp */
    out = run_ts("hello", "");
    CHECK("single line: output is non-null",          out != NULL);
    CHECK("single line: contains 'hello'",            out && strstr(out, "hello"));
    CHECK("single line: exactly one timestamp",       out && count_occurrences(out, "[") == 1);
    CHECK("single line: timestamp looks valid",       out && looks_like_timestamp(out));
    free(out);

    /* Two lines: should produce two timestamps */
    out = run_ts("foo\\nbar", "");
    CHECK("two lines: contains 'foo'",                out && strstr(out, "foo"));
    CHECK("two lines: contains 'bar'",                out && strstr(out, "bar"));
    CHECK("two lines: exactly two timestamps",        out && count_occurrences(out, "[") == 2);
    free(out);

    /* Three lines */
    out = run_ts("a\\nb\\nc", "");
    CHECK("three lines: exactly three timestamps",    out && count_occurrences(out, "[") == 3);
    free(out);

    /* Custom separator: pipe */
    out = run_ts("foo|bar|baz", "-s '|'");
    CHECK("pipe sep: contains 'foo'",                 out && strstr(out, "foo"));
    CHECK("pipe sep: contains 'bar'",                 out && strstr(out, "bar"));
    CHECK("pipe sep: contains 'baz'",                 out && strstr(out, "baz"));
    CHECK("pipe sep: exactly three timestamps",       out && count_occurrences(out, "[") == 3);
    free(out);

    /* Custom separator: multi-char */
    out = run_ts("one---two---three", "-s '---'");
    CHECK("multi-char sep: exactly three timestamps", out && count_occurrences(out, "[") == 3);
    free(out);

    /* KMP overlapping separator: 'aba' in 'ababa' should match twice */
    out = run_ts("ababa", "-s 'aba'");
    CHECK("overlapping sep: 'aba' in 'ababa' = two timestamps",
          out && count_occurrences(out, "[") == 2);
    free(out);

    /* Custom format */
    out = run_ts("hello", "-f '[%H:%M:%S] '");
    CHECK("custom fmt: output non-null",              out != NULL);
    CHECK("custom fmt: contains 'hello'",             out && strstr(out, "hello"));
    CHECK("custom fmt: contains colon-separated time",
          out && strstr(out, ":") != NULL);
    free(out);

    /* Empty input: should produce no output */
    out = run_ts("", "");
    CHECK("empty input: no output",                   out && strlen(out) == 0);
    free(out);

    printf("\n");
}

/* -------------------------------------------------------------------------
 * Benchmark
 * --------------------------------------------------------------------- */

static double now_seconds(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

static void benchmark(void) {
    printf("=== Benchmark ===\n");

    /* Write a temp file with 100k lines of 79 chars each */
    const int    N_LINES  = 100000;
    const int    LINE_LEN = 79;
    const char  *TMPFILE  = "/tmp/ts_bench_input.txt";

    FILE *f = fopen(TMPFILE, "w");
    if (!f) { perror("fopen"); return; }
    for (int i = 0; i < N_LINES; i++) {
        for (int j = 0; j < LINE_LEN; j++) fputc('x', f);
        fputc('\n', f);
    }
    fclose(f);

    double total_mb = (N_LINES * (LINE_LEN + 1)) / (1024.0 * 1024.0);

    /* Benchmark via stdin pipe to avoid argument-length limits on large input */
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "cat %s | %s > /dev/null", TMPFILE, TS_BIN);

    const int REPS = 5;
    double best = 1e18;

    for (int r = 0; r < REPS; r++) {
        double t0 = now_seconds();
        int ret = system(cmd);
        double t1 = now_seconds();
        (void)ret;
        double elapsed = t1 - t0;
        if (elapsed < best) best = elapsed;
    }

    printf("  Input:      %.1f MB  (%d lines)\n", total_mb, N_LINES);
    printf("  Best of %d:  %.1f ms\n", REPS, best * 1000.0);
    printf("  Throughput: %.0f MB/s\n", total_mb / best);

    remove(TMPFILE);
    printf("\n");
}

/* -------------------------------------------------------------------------
 * Entry point
 * --------------------------------------------------------------------- */

int main(void) {
    test_correctness();
    benchmark();
    printf("=== Results: %d / %d passed ===\n", tests_passed, tests_run);
    return (tests_passed == tests_run) ? 0 : 1;
}
