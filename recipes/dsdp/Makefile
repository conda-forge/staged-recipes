# make PREFIX=`pwd` -f ..dsdp.mk
SRC = $(shell find src -name *.c)
OBJ = $(SRC:%.c=%.o)

LAPACKBLAS ?= -L$(PREFIX)/lib -lopenblas

CFLAGS = -Wall -O3 -fPIC 
CPPFLAGS = -DDSDP_TIME -Iinclude -Isrc/solver -Isrc/sdp

ifeq ($(shell uname -s),Darwin)
	DYNAMIC_EXT ?= dylib
else
	DYNAMIC_EXT ?= so
	LDFLAGS += -lm
endif
PREFIX ?= $(shell pwd)

.PHONY: obj install clean

obj: $(OBJ)

install: $(PREFIX)/lib/libdsdp.$(DYNAMIC_EXT) $(PREFIX)/bin/dsdp5
	cp include/*.h $(PREFIX)/include

# Create macOS dynamic library (.dylib)
$(PREFIX)/lib/libdsdp.dylib: $(OBJ)
	libtool -dynamic -install_name $@ \
		-current_version 5.8 -compatibility_version 5.8 \
		-o $@ \
		$(OBJ) $(LAPACKBLAS) -lSystem

# Create Linux shared library (.so)
$(PREFIX)/lib/libdsdp.so: $(OBJ)
	$(CC) -shared -Wl,-soname,$@ \
		-o $@ \
		$(OBJ) $(LAPACKBLAS)

# Build DSDP binary 
$(PREFIX)/bin/dsdp5: LDFLAGS += -L$(PREFIX)/lib -ldsdp $(LAPACKBLAS) -Wl,-rpath,$(PREFIX)/lib
$(PREFIX)/bin/dsdp5: examples/readsdpa.o $(PREFIX)/lib/libdsdp.$(DYNAMIC_EXT)
	$(CC) $< $(LDFLAGS) -o $@

clean:
	-$(RM) $(OBJ)
	-$(RM) examples/readsdpa.o
	-$(RM) $(PREFIX)/lib/libdsdp.*
	-$(RM) $(PREFIX)/bin/dsdp5

