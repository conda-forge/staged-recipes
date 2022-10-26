TARGET = gw


CXX = clang++
CXXFLAGS = -g -Wall -std=c++17  -fno-common -dynamic -fwrapv -O3 -DNDEBUG

INCLUDE = -I./include -I./src -I. -I./gw -I/usr/local/include

# Options to use target htslib or skia
HTSLIB ?= ""
ifneq ($(HTSLIB),"")
	INCLUDE += -I$(HTSLIB)
	LINK += -L$(HTSLIB)
endif

SKIA ?= ""
ifneq ($(SKIA),"")
	INCLUDE += -I$(SKIA)
	LINK += -L $(wildcard $(SKIA)/out/Rel*)
else
	INCLUDE += -I./lib/skia
	LINK = -L $(wildcard ../skia/out/Rel*)
endif


LIBS = -lskia -lm -ldl -licu -ljpeg -lpng -lsvg -lzlib -lhts -lfontconfig -lpthread -lglfw3 -luuid

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	ifeq (${XDG_SESSION_TYPE},"wayland")
		LIBS += -lwayland-client
	else
		LIBS += -lX11
	endif
endif
ifeq ($(UNAME_S),Darwin)
	#LIBS += -lglfw3
endif

.PHONY: default all debug clean

default: $(TARGET)

all: default
debug: default

# windows untested here
IS_DARWIN=0
SKIA_LINK =
ifeq ($(OS),Windows_NT)
    CXXFLAGS += -lglfw3 -D WIN32
    SKIA_LINK = https://github.com/JetBrains/skia-build/releases/download/m93-87e8842e8c/Skia-m93-87e8842e8c-windows-Release-x64.zip
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        CXXFLAGS += -D LINUX
        LIBS += -lGL -lfreetype -lfontconfig
        SKIA_LINK = https://github.com/JetBrains/skia-build/releases/download/m93-87e8842e8c/Skia-m93-87e8842e8c-linux-Release-x64.zip
    endif
    ifeq ($(UNAME_S),Darwin)
    	IS_DARWIN = 1
        CXXFLAGS += -D OSX -stdlib=libc++ -arch x86_64 -fvisibility=hidden  # -mmacosx-version-min=10.15
        SKIA_LINK = https://github.com/JetBrains/skia-build/releases/download/m93-87e8842e8c/Skia-m93-87e8842e8c-macos-Release-x64.zip
    endif
    ifeq ($(UNAME_S),arm64)
		IS_DARWIN = 1
		CXXFLAGS += -D OSX -stdlib=libc++ -arch arm64 -fvisibility=hidden
		SKIA_LINK = https://github.com/JetBrains/skia-build/releases/download/m93-87e8842e8c/Skia-m93-87e8842e8c-macos-Release-arm64.zip
    endif
endif

CXXFLAGS_link = $(CXXFLAGS)
ifeq ($(IS_DARWIN),1)
	CXXFLAGS_link += -undefined dynamic_lookup -framework OpenGL -framework AppKit -framework ApplicationServices
endif


OBJECTS = $(patsubst %.cpp, %.o, $(wildcard ./src/*.cpp))

prep:
	$(info "System: $(shell uname -s)")
	$(info "Downloading pre-build skia skia from: $(SKIA_LINK)")
	wget -O lib/skia/skia.zip $(SKIA_LINK)
	cd lib/skia && unzip -o skia.zip && rm skia.zip && cd ../../


LINK = -L./lib/skia/out/Release-x64 -L/usr/local/lib

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -g $(INCLUDE) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)


$(TARGET): $(OBJECTS)
	ls /
	$(CXX) $(CXXFLAGS_link) -g $(OBJECTS) $(LINK) $(LIBS) -o $@

clean:
	-rm -f *.o ./src/*.o ./src/*.o.tmp
	-rm -f $(TARGET)
