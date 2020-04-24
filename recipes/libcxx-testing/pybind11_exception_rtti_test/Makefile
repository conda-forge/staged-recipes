COMP=${CXX}
ifeq ($(shell uname -s), Linux)
EXTRA_FLAGS=
PRINTLIBS=LD_LIBRARY_PATH=../src
SUFFIX=$(shell python3-config --extension-suffix)
SOEXT=.so
else
EXTRA_FLAGS=-undefined dynamic_lookup
PRINTLIBS=DYLD_FALLBACK_LIBRARY_PATH=../src DYLD_PRINT_LIBRARIES=YES
SUFFIX=$(shell python3-config --extension-suffix)
SOEXT=.dylib
endif

test: clean pymod
	cd tests && \
	${COMP} ${CXXFLAGS} ${LDFLAGS} ${EXTRA_FLAGS} -shared -fPIC \
		`python -m pybind11 --includes` \
		testLib.cc \
		-L../src -lException \
		-o testLib${SUFFIX} && \
		echo "\n\n============================================\ntesting\n============================================\n" && \
	  ${PRINTLIBS} python test_exception_catching_python.py && \
	cd -

# chmod u+x testLib`python3-config --extension-suffix` && \

pymod: cpp
	cd exception_test && \
	${COMP} ${CXXFLAGS} ${LDFLAGS} ${EXTRA_FLAGS} -shared -fPIC \
		`python -m pybind11 --includes` \
		exceptions.cc \
		-L../src -lException \
		-o exceptions${SUFFIX} && \
	cd - && \
	python -m pip install -e .

cpp:
	cd src && \
	${COMP} ${CXXFLAGS} ${LDFLAGS} ${EXTRA_FLAGS} -shared -fPIC \
		Exception.cc \
		-o libException${SOEXT} && \
	cd -

clean:
	rm -f \
		src/*.o src/*.so src/*.dylib \
		tests/*.o tests/*.so tests/*.dylib \
		exception_test/*.o exception_test/*.so exception_test/*.dylib
