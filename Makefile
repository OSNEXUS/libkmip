##
## Makefile for libkmip
##
.POSIX:
.SUFFIXES:

SRC_DIR = src
INC_DIR = include
BIN_DIR = bin
OBJ_DIR = obj
LIB_DIR = lib
TEST_DIR = tests
DEMO_DIR = demos
DEST_DIR =
DOCS_DIR = docs
PREFIX = /usr/local
KMIP = kmip

MAJOR    = 0
MINOR    = 2
MICRO    = 0
VERSION  = $(MAJOR).$(MINOR)
ARCNAME  = libkmip.a
LINKNAME = libkmip.so
SONAME   = $(LINKNAME).$(MAJOR)
LIBNAME  = $(LINKNAME).$(VERSION)
LIBS     = $(LIBNAME) $(ARCNAME)

CC      = gcc
#CFLAGS = -std=c11 -pedantic -g3 -Og -Wall -Wextra
CFLAGS  = -std=c11 -pedantic -g3 -Wall -Wextra
LOFLAGS = -fPIC
SOFLAGS = -shared -Wl,-soname,$(SONAME)
LDFLAGS = -Wl,-rpath=/sandbox/quantastor/external/openssl/linux/gcc48/openssl-1.1.1k/lib \
		-L/sandbox/quantastor/external/openssl/linux/gcc48/openssl-1.1.1k/lib \
		-Wl,-rpath=/opt/osnexus/common/lib \
		-L/opt/osnexus/common/lib
LDLIBS  = -lssl -lcrypto
INCFLAGS = -I/sandbox/quantastor/external/openssl/linux/gcc48/openssl-1.1.1k/include
AR      = ar csrv
DESTDIR = 
PREFIX  = /usr/local
KMIP    = kmip

OFILES  = kmip.o kmip_memset.o kmip_bio.o
LOFILES = kmip.lo kmip_memset.lo kmip_bio.lo

all: demos tests $(LIBS)

test: tests
	$(BIN_DIR)/tests

## Dynamic directory creation rules
$(BIN_DIR):
	mkdir -p $@
$(OBJ_DIR):
	mkdir -p $@
$(LIB_DIR):
	mkdir -p $@

## Install targets
install: all
	mkdir -p $(DEST_DIR)$(PREFIX)/bin/$(KMIP)
	mkdir -p $(DEST_DIR)$(PREFIX)/include/$(KMIP)
	mkdir -p $(DEST_DIR)$(PREFIX)/lib
	mkdir -p $(DEST_DIR)$(PREFIX)/src/$(KMIP)
	mkdir -p $(DEST_DIR)$(PREFIX)/share/doc/$(KMIP)/src
	cp $(BIN_DIR)/demo_create $(DEST_DIR)$(PREFIX)/bin/$(KMIP)
	cp $(BIN_DIR)/demo_get $(DEST_DIR)$(PREFIX)/bin/$(KMIP)
	cp $(BIN_DIR)/demo_destroy $(DEST_DIR)$(PREFIX)/bin/$(KMIP)
	cp $(BIN_DIR)/demo_query $(DEST_DIR)$(PREFIX)/bin/$(KMIP)
	cp -r $(DOCS_DIR)/source/. $(DEST_DIR)$(PREFIX)/share/doc/$(KMIP)/src
	cp $(SRC_DIR)/*.c $(DEST_DIR)$(PREFIX)/src/$(KMIP)
	cp $(INC_DIR)/*.h $(DEST_DIR)$(PREFIX)/include/$(KMIP)
	cp $(LIB_DIR)/$(LIB_NAME) $(DEST_DIR)$(PREFIX)/lib
	cp $(LIB_DIR)/$(ARC_NAME) $(DEST_DIR)$(PREFIX)/lib
	cd $(DEST_DIR)$(PREFIX)/lib && ln -s $(LIB_NAME) $(LINK_NAME) && cd -

install_html_docs: html_docs
	mkdir -p $(DEST_DIR)$(PREFIX)/share/doc/$(KMIP)/html
	cp -r $(DOCS_DIR)/build/html/. $(DEST_DIR)$(PREFIX)/share/doc/$(KMIP)/html

uninstall:
	rm -rf $(DEST_DIR)$(PREFIX)/bin/$(KMIP)
	rm -rf $(DEST_DIR)$(PREFIX)/include/$(KMIP)
	rm -rf $(DEST_DIR)$(PREFIX)/src/$(KMIP)
	rm -rf $(DEST_DIR)$(PREFIX)/share/doc/$(KMIP)
	rm -r $(DEST_DIR)$(PREFIX)/lib/$(LINK_NAME)*
	rm -r $(DEST_DIR)$(PREFIX)/lib/$(ARC_NAME)

uninstall_html_docs:
	rm -rf $(DEST_DIR)$(PREFIX)/share/doc/$(KMIP)/html

docs: html_docs
html_docs:
	cd $(SRCDIR)/docs && make html && cd -
demos: demo_create demo_get demo_destroy
demo_get: demo_get.o $(OFILES)
	$(CC) $(LDFLAGS) -o demo_get $? $(LDLIBS)
demo_create: demo_create.o $(OFILES)
	$(CC) $(LDFLAGS) -o demo_create $? $(LDLIBS)
demo_destroy: demo_destroy.o $(OFILES)
	$(CC) $(LDFLAGS) -o demo_destroy $? $(LDLIBS)
tests: tests.o kmip.o kmip_memset.o
	$(CC) $(LDFLAGS) -o tests tests.o kmip.o kmip_memset.o

demo_get.o: demo_get.c kmip_memset.h kmip.h
demo_create.o: demo_create.c kmip_memset.h kmip.h
demo_destroy.o: demo_destroy.c kmip_memset.h kmip.h
tests.o: tests.c kmip_memset.h kmip.h
$(LIBNAME): $(LOFILES)
	$(CC) $(CFLAGS) $(SOFLAGS) $(LDFLAGS) -o $@ $(LOFILES) $(LDLIBS)
$(ARCNAME): $(OFILES)
	$(AR) $@ $(OFILES)

kmip.o: kmip.c kmip.h kmip_memset.h
kmip.lo: kmip.c kmip.h kmip_memset.h

kmip_memset.o: kmip_memset.c kmip_memset.h
kmip_memset.lo: kmip_memset.c kmip_memset.h

kmip_bio.o: kmip_bio.c kmip_bio.h
kmip_bio.lo: kmip_bio.c kmip_bio.h

## Clean up rules
clean:
	rm -rf $(BIN_DIR) $(OBJ_DIR) $(LIB_DIR)
clean_html_docs:
	cd docs && make clean && cd ..
cleanest:
	rm -f demo_create demo_get demo_destroy tests *.o $(LOFILES) $(LIBS)
	cd docs && make clean && cd ..

.SUFFIXES: .c .o .lo .so
.c.o:
	$(CC) $(INCFLAGS) $(CFLAGS) -c $<
.c.lo:
	$(CC) $(INCFLAGS) $(CFLAGS) $(LDFLAGS) $(LOFLAGS) -c $< -o $@ $(LDLIBS)
#.lo.so:
#	$(CC) $(CFLAGS) $(SOFLAGS) -o $@ $?
