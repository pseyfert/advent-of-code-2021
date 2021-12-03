all: types_rflx.so types.so

headers := $(wildcard include/*.h)

CPPFLAGS = $(shell cling-config --cppflags) -march=native -Iinclude -Wall -Wextra -O3

types_rflx.cpp: selection.xml $(headers)
	genreflex --verbose -s $< -o $@ $(headers) --cxxflags $(CPPFLAGS)

types_rflx.so: types_rflx.cpp
	g++ $(shell cling-config --cppflags) -fPIC -shared -o $@ $< $(CPPFLAGS)

types.so: src/types.cpp $(headers)
	g++ $< -o $@ -fPIC -shared $(CPPFLAGS)

install:
	pip install cppyy

clean:
	rm -f types_rflx.cpp types_rflx_rdict.pcm types_rflx.so types.so include/types.h.gch
