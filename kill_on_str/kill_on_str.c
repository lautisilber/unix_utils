/* kill_on_string.c
 *
 * Usage:
 *   producer | kill_on_string "PATTERN" | consumer
 *
 * Streams stdin to stdout unchanged (byte for byte, as it arrives), and
 * if PATTERN ever appears in the stream, kills the *entire* pipeline
 * (not just itself) by sending SIGTERM to its own process group.
 *
 * This relies on the shell (bash/zsh/dash under job control, etc.)
 * having put every process in the pipeline into a single process
 * group, which is standard behavior for a plain `a | b | c` pipeline.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>

#define BUFFER_SIZE 4096

static void usage(const char *prog) {
    fprintf(stderr, "usage: %s <pattern>\n", prog);
}

int main(int argc, char *argv[]) {
    const char *prog = argv[0];

    if (argc != 2) {
        usage(prog);
        return 2;
    }

    const char *needle = argv[1];
    const size_t needle_len = strlen(needle);
    if (needle_len == 0) {
        fprintf(stderr, "%s: pattern must not be empty\n", prog);
        return 2;
    }

    // Don't die if the downstream reader (e.g. tee) has already exited;
    // we want to detect EPIPE ourselves and handle it.
    signal(SIGPIPE, SIG_IGN);


    // allocate buffer
    char *buffer = (char *)malloc(needle_len + BUFFER_SIZE + 1);
    if (!buffer) {
        perror("malloc");
        return 1;
    }
    memset(buffer, 0, needle_len + BUFFER_SIZE + 1);

    // carry_len = how many REAL bytes of carried-over data currently sit
    // in buffer[needle_len - carry_len .. needle_len). Starts at 0: on
    // the first read there is no prior data, so nothing is carried and
    // nothing synthetic is ever matched against.
    size_t carry_len = 0;

    // main loop
    for (;;) {
        ssize_t n = read(STDIN_FILENO, buffer + needle_len, BUFFER_SIZE);
        if (n < 0) {
            if (errno == EINTR) continue;
            perror("read");
            free(buffer);
            return 1;
        }
        if (n == 0) break; // EOF

        // forward stdin
        for (ssize_t written = 0; written < n;) {
            ssize_t w = write(STDOUT_FILENO, buffer + needle_len + written, (size_t)(n - written));
            if (w < 0) {
                if (errno == EINTR) continue;
                free(buffer);
                if (errno == EPIPE) return 0; // downstream gone
                perror("write");
                return 1;
            }
            written += w;
        }
        fflush(stdout);

        // Only the carry_len real carried-over bytes plus the n bytes
        // just read are valid data - that's the only window we search.
        // (On the very first read carry_len is 0, so this is just the
        // n freshly-read bytes: no synthetic/poisoned data involved.)
        char *window = buffer + needle_len - carry_len;
        const size_t window_len = carry_len + (size_t)n;
        if (memmem(window, window_len, needle, needle_len) != NULL) {
            fflush(stdout);
            fprintf(stderr, "kill_on_str: pattern \"%s\" matched, killing pipeline\n", needle);
            fflush(stderr);

            usleep(100000); // give downstream (e.g. tee) time to drain the pipe and flush before we kill it too
            // pid/pgid 0 => our own process group. In a normal shell
            // pipeline that group contains every command in the pipe.
            kill(0, SIGTERM);
            free(buffer);
            return 1;
        }

        // Update the carry: keep the last up-to-(needle_len-1) real
        // bytes we've seen so far, for boundary matches on the next read.
        carry_len = window_len < needle_len - 1 ? window_len : needle_len - 1;
        if (carry_len > 0) {
            // overlap when window_len < needle_len.
            memmove(buffer + needle_len - carry_len, window + window_len - carry_len, carry_len);
        }
    }

    free(buffer);
    return 0;
}
