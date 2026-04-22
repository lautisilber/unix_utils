UNAME   = $(shell uname)
ifeq ($(UNAME), Darwin)
  CC    = clang
else
  CC    = gcc
endif
CFLAGS  = -O2 -Wall -Wextra -std=c11
PREFIX  = /usr/local
BINDIR  = $(PREFIX)/bin
BUILD   = build

.PHONY: all test install uninstall clean
.SILENT:

all: $(BUILD)/ts

$(BUILD)/ts: ts.c | $(BUILD)
	$(CC) $(CFLAGS) -o $@ $<

test: $(BUILD)/ts $(BUILD)/ts_test
	$(BUILD)/ts_test

$(BUILD)/ts_test: ts_test.c | $(BUILD)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD):
	mkdir -p $(BUILD)

install: $(BUILD)/ts
	install -d $(BINDIR)
	install -m 755 $(BUILD)/ts $(BINDIR)/ts

uninstall:
	rm -f $(BINDIR)/ts

clean:
	rm -rf $(BUILD)
