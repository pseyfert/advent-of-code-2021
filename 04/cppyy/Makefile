all: api_rflx.so impl.so

pub_headers := $(wildcard include/public/*.h)
int_headers := $(wildcard include/internal/*.h)
impl_objs := $(patsubst %.cpp,%.o,$(wildcard src/*.cpp))
test_objs := $(patsubst %.cpp,%.o,$(wildcard test/*.cpp))

CPPFLAGS = -march=native -Iinclude -Wall -Wextra -Og -fPIC -ggdb
CLING_CPPFLAGS = $(shell cling-config --cppflags) $(CPPFLAGS)
IMPL_CPPFLAGS = $(CPPFLAGS) -std=c++20
LDLIBS = -lfmt -lglog

api_rflx.cpp: selection.xml $(pub_headers)
	genreflex --verbose -s $< -o $@ $(pub_headers) --cxxflags $(CLING_CPPFLAGS)

api_rflx.so: api_rflx.cpp
	g++ $(CLING_CPPFLAGS) -shared -o $@ $<

test/%.o: test/%.cpp $(int_headers) $(pub_headers)
	g++ $(IMPL_CPPFLAGS) $< -o $@ -c -pthread

test/test: $(impl_objs) $(test_objs)
	g++ $(IMPL_CPPFLAGS) $^ -o $@ -lgtest_main -lgtest -pthread $(LDLIBS)

src/%.o: src/%.cpp $(int_headers) $(pub_headers)
	g++ $(IMPL_CPPFLAGS) $< -o $@ -c -pthread

impl.so: $(impl_objs)
	g++ $^ -o $@ -shared $(CPPFLAGS)  $(LDLIBS)

clean:
	rm -f */*.o test/test *.so *.pcm *_rflx*
