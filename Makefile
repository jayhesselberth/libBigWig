CC = gcc
AR = ar
RANLIB = ranlib
CFLAGS = -g -Wall
LIBS = -lcurl
EXTRA_CFLAGS_PIC = -fpic
LDFLAGS =
LDLIBS =
INCLUDES = 

prefix = /usr/local
includedir = $(prefix)/include
libdir = $(exec_prefix)/lib

.PHONY: all clean lib test doc

.SUFFIXES: .c .o .pico

all: lib

lib: lib-static lib-shared

lib-static: libBigWig.a

lib-shared: libBigWig.so

doc:
	doxygen

OBJS = io.o bwValues.o bwRead.o bwStats.o

.c.o:
	$(CC) -I. $(CFLAGS) $(INCLUDES) -c -o $@ $<

.c.pico:
	$(CC) -I. $(CFLAGS) $(INCLUDES) $(EXTRA_CFLAGS_PIC) -c -o $@ $<

libBigWig.a: $(OBJS)
	-@rm -f $@
	$(AR) -rcs $@ $(OBJS)
	$(RANLIB) $@

libBigWig.so: $(OBJS:.o=.pico)
	$(CC) -shared $(LDFLAGS) -o $@ $(OBJS:.o=.pico) $(LDLIBS) -lcurl

test/test: libBigWig.a
	gcc -o $@ -I. $(CFLAGS) test/test.c libBigWig.a -lcurl -lz -lm
	./test/test test/test.bw

test: test/test

clean:
	rm -f *.o libBigWig.a libBigWig.so *.pico test/test

install: libBigWig.a
	install libBigWig.a $(prefix)/lib
	install bigWig.h $(prefix)/include
