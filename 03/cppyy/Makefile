all: test/test

test/test.o: include/interface.h include/funcs.h test/test.cc
	g++ -Wall -Wextra -std=c++20 -Iinclude -O3 test/test.cc -c -o test/test.o -lgtest_main -lgtest -pthread

test/test: test/test.o src/funcs.o
	g++ -Wall -Wextra -std=c++20 -Iinclude -O3 test/test.o src/funcs.o -o test/test -lgtest_main -lgtest -pthread

src/funcs.o: include/interface.h include/funcs.h src/funcs.cpp
	g++ -Wall -Wextra -std=c++20 -Iinclude -O3 src/funcs.cpp -o src/funcs.o -c -pthread

clean:
	rm -f */*.o test/test
