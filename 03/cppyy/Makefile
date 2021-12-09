all: test/test funcs_rflx.so funcs.so

headers := $(wildcard include/*.h)

CPPFLAGS = $(shell cling-config --cppflags) -march=native -Iinclude -Wall -Wextra -O3

funcs_rflx.cpp: selection.xml include/interface.h
	genreflex --verbose -s $< -o $@ include/interface.h --cxxflags $(CPPFLAGS)

funcs_rflx.so: funcs_rflx.cpp
	g++ $(shell cling-config --cppflags) -fPIC -shared -o $@ $< $(CPPFLAGS)

test/test.o: test/test.cc $(headers)
	g++ -Wall -Wextra -std=c++20 -Iinclude -O3 $< -c -o $@ -lgtest_main -lgtest -pthread

test/test: test/test.o src/funcs.o
	g++ -Wall -Wextra -std=c++20 -Iinclude -O3 $^ -o $@ -lgtest_main -lgtest -pthread

src/funcs.o: src/funcs.cpp $(headers)
	g++ -Wall -Wextra -std=c++20 -Iinclude -O3 $< -o $@ -c -pthread

src/funcs.os: src/funcs.cpp $(headers)
	g++ -Wall -Wextra -std=c++20 -Iinclude -O3 $< -o $@ -c -pthread -fPIC

funcs.so: src/funcs.os
	g++ $< -o $@ -fPIC -shared $(CPPFLAGS)

clean:
	rm -f */*.o test/test
