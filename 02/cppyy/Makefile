all: types_rflx.so types.so

headers := $(wildcard include/*.h)

types_rflx.cpp: selection.xml include/types.h
	genreflex --verbose -s $< -o $@ $(headers) --cxxflags $(shell cling-config --cppflags)

types_rflx.so: types_rflx.cpp
	g++ $(shell cling-config --cppflags) -fPIC -shared -o $@ -Iinclude $< -Wall -Wextra -O3 -march=native

types.so: src/types.cpp
	g++ $< -o $@ -Iinclude -fPIC -shared $(shell cling-config --cppflags) -Wall -Wextra -O3 -march=native

install:
	pip install cppyy

clean:
	rm -f types_rflx.cpp types_rflx_rdict.pcm types_rflx.so types.so include/types.h.gch
