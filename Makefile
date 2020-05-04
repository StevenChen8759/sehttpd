.PHONY: all check clean
TARGET = sehttpd
GIT_HOOKS := .git/hooks/applied
all: $(GIT_HOOKS) $(TARGET) htstress

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

include common.mk

CFLAGS = -I./src
CFLAGS += -O2
CFLAGS += -std=gnu99 -Wall -W
CFLAGS += -DUNUSED="__attribute__((unused))"
CFLAGS += -DNDEBUG
LDFLAGS =

# standard build rules
.SUFFIXES: .o .c
.c.o:
	$(VECHO) "  CC\t$@\n"
	$(Q)$(CC) -o $@ $(CFLAGS) -c -MMD -MF $@.d $<

OBJS = \
    src/http.o \
    src/http_parser.o \
    src/http_request.o \
    src/timer.o \
    src/mainloop.o
deps += $(OBJS:%.o=%.o.d)

$(TARGET): $(OBJS)
	$(VECHO) "  LD\t$@\n"
	$(Q)$(CC) -o $@ $^ $(LDFLAGS)

check: all
	@scripts/test.sh

strperf: htstress
	./htstress -n 100000 -c 4 -t 4 http://127.0.0.1:8081$(URI)

CFLAGS_user = -std=gnu99 -Wall -Wextra -Werror -g
LDFLAGS_user = -lpthread

htstress: htstress.c
	$(CC) $(CFLAGS_user) -o $@ $< $(LDFLAGS_user)

clean:
	$(VECHO) "  Cleaning...\n"
	$(Q)$(RM) $(TARGET) $(OBJS) $(deps)

-include $(deps)

