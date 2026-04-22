#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
#include <stdint.h>

#define TIMESTR_BUF_LEN 128

const char sep_default[] = "\n";
const char fmt_default[] = "[%Y/%m/%d %H:%M:%S]: ";

#define STR_ARG_FLAG_POPULATED (1 << 0)
#define STR_ARG_FLAG_HEAP      (1 << 1)
typedef struct {
    const char *names[2];
    const char *str;
    size_t str_len;
    uint8_t flags;
} StrArg;

static int unescape(char *s) {
    // convert a user input of chars '\' and 'n' to the ascii code 0x0A
    int r = 0, w = 0;
    while (s[r]) {
        if (s[r] == '\\' && s[r + 1]) {
            r++;
            switch (s[r]) {
                case 'n':  s[w++] = '\n'; break;
                case 't':  s[w++] = '\t'; break;
                case 'r':  s[w++] = '\r'; break;
                case '\\': s[w++] = '\\'; break;
                case '0':  s[w++] = '\0'; break;
                default:   s[w++] = '\\'; s[w++] = s[r]; break;
            }
        } else {
            s[w++] = s[r];
        }
        r++;
    }
    s[w] = '\0';
    return w;
}

static void arg_populate_from_argv(StrArg *str_arg, char *arg) {
    str_arg->str = strdup(arg);
    if (!str_arg->str) {
        perror("Couldn't allocate memory");
        exit(3);
    }
    str_arg->str_len = strlen(str_arg->str);
    str_arg->flags = STR_ARG_FLAG_POPULATED | STR_ARG_FLAG_HEAP;
}

static void arg_populate_from_static_ptr(StrArg *str_arg, const char *arg) {
    str_arg->str = arg;
    str_arg->str_len = strlen(str_arg->str);
    str_arg->flags = STR_ARG_FLAG_POPULATED;
}

static bool arg_is_populated(StrArg *str_arg) {
    return str_arg->flags & STR_ARG_FLAG_POPULATED;
}

static void arg_destroy(StrArg *str_arg) {
    const uint8_t f = STR_ARG_FLAG_POPULATED | STR_ARG_FLAG_HEAP;
    if ((str_arg->flags & f) == f && str_arg->str) {
        free((void *)str_arg->str);
    }
    str_arg->str_len = 0;
    str_arg->flags = 0;
}

static bool parse_argv_str(StrArg **all_args, const size_t n_args, const char *argname, char *arg) {
    for (size_t i = 0; i < n_args; ++i) {
        StrArg *a = all_args[i];

        bool matches_name = false;
        for (int i = 0; i < 2; ++i) {
            if (!strlen(a->names[i])) { continue; }
            if (strcmp(a->names[i], argname) == 0) {
                matches_name = true;
                break;
            }
        }

        if (!matches_name) {
            continue;
        }

        if (arg_is_populated(a)) {
            fprintf(stderr, "Can't pass multiple arguments for parameter %s\n", arg);
            exit(2);
        }

        arg_populate_from_argv(a, arg);
        return true;
    }

    return false;
}

static void get_tm(struct tm *now) {
    time_t now_time = time(NULL);
    localtime_r(&now_time, now);
}

static size_t get_time_str(char buf[TIMESTR_BUF_LEN], const char *fmt) {
    struct tm now;
    get_tm(&now);

    return strftime(buf, TIMESTR_BUF_LEN, fmt, &now);
}

static bool check_time_format_string(const char *fmt) {
    char timestr[TIMESTR_BUF_LEN] = {0};
    return get_time_str(timestr, fmt) > 0;
}

StrArg fmt = {{"-f", "--fmt"}, NULL, 0, 0};
StrArg sep = {{"-s", "--sep"}, NULL, 0, 0};

const char *source = NULL; // null means stdin
static bool get_next_char(char *c) {
    static size_t i = 0;
    if (source) {
        *c = source[i++];
        bool success = *c != '\0';
        if (!success) { i = 0; }
        return success;
    } else {
        int d = getchar();
        if (d == EOF) {
            *c = '\0';
            return false;
        } else {
            *c = d;
            return true;
        }
    }
}

int main(int argc, char *argv[]) {
    // Parse arguments
    {
        StrArg *all_args[] = {
            &fmt, &sep
        };
        const size_t n_args = sizeof(all_args)/sizeof(all_args[0]);

        for (int i = 1; i < argc; i++) {
            if (i + 1 < argc) {
                unescape(argv[i+1]);
                if (parse_argv_str(all_args, n_args, argv[i], argv[i+1])) {
                    ++i;
                    continue;
                }
            }

            if (source) {
                fprintf(stderr, "Can't have two input strings\n");
                return 1;
            }
            unescape(argv[i]);
            source = argv[i];
        }
    }

    // Complete with default arguments
    if (!arg_is_populated(&sep)) {
        arg_populate_from_static_ptr(&sep, sep_default);
    }
    if (!arg_is_populated(&fmt)) {
        arg_populate_from_static_ptr(&fmt, fmt_default);
    }

    // Check all arguments were populated
    if (!arg_is_populated(&sep) || !arg_is_populated(&fmt)) {
        fprintf(stderr, "Usage: ts [-s,--sep separator] [-f,--fmt timestamp formatting]\n");
        return 1;
    }

    // Check all arguments were right
    if (!check_time_format_string(fmt.str)) {
        fprintf(stderr, "Bad strftime format string '%s'\n", fmt.str);
        return 1;
    }

    // Build KMP failure table for separator
    size_t *fail = calloc(sep.str_len, sizeof(size_t));
    if (!fail) { perror("calloc"); return 1; }
    fail[0] = 0;
    for (size_t i = 1; i < sep.str_len; i++) {
        size_t j = fail[i - 1];
        while (j > 0 && sep.str[i] != sep.str[j])
            j = fail[j - 1];
        if (sep.str[i] == sep.str[j])
            j++;
        fail[i] = j;
    }

    // main loop
    char timestr[TIMESTR_BUF_LEN] = {0};
    size_t sepidx = sep.str_len;
    char c;
    while (get_next_char(&c)) {
        if (sepidx == sep.str_len) {
            get_time_str(timestr, fmt.str);
            fputs(timestr, stdout);
            sepidx = 0;
        }

        // check if we are reading a sep sequence
        while (sepidx > 0 && c != sep.str[sepidx]) {
            sepidx = fail[sepidx - 1];   // follow failure links
        } if (c == sep.str[sepidx]) {
            sepidx++;
        }

        putchar(c);
    }

    if (source) { putchar('\n'); }

    free(fail);
    // destroy all arguments
    arg_destroy(&sep);
    arg_destroy(&fmt);
}
