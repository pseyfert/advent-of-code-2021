#include <fstream>
#include <stdio.h>
#include <iostream>
#include <vector>
#include <ranges>

int idx_lookup_h(int x, int y);

int read_lookup(int x, int y) {
  return x + (COLS-PADDING)*y;
}


int read(std::array<int, 512>& LUT, std::vector<int>& data, char* inf) {
  std::vector<int> read_image((ROWS-PADDING)*(COLS-PADDING), 0);
  std::ifstream input(inf);

  bool first_skip_done = false;
  std::size_t idx = 0;
  while (true) {
    char c;
    input.read(&c, sizeof(char));
    if (!first_skip_done && c=='#') {
      LUT[idx++] = 1;
    } else if (!first_skip_done && c=='.') {
      LUT[idx++] = 0;
    } else if (c=='\n' && first_skip_done) {
      break;
    } else if (c=='\n') {
      printf("done reading the LUT at index %d\n", idx);
      first_skip_done = true;
    }
  }

  idx = 0;
  while (true) {
    char c;
    input.read(&c, sizeof(char));
    if (c=='#') {
      read_image[idx++] = 1;
    } else if (c=='.') {
      read_image[idx++] = 0;
    } else if (c=='\n' && idx == read_image.size()) {
      break;
    } else if (c=='\n') {
      continue;
    } else {
      return 2;
    }
  }

  for (std::size_t ix = 0; ix < COLS-PADDING; ++ix) {
    for (std::size_t iy = 0; iy < ROWS-PADDING; ++iy) {
      data[idx_lookup_h(ix+PADDING/2,iy+PADDING/2)] = read_image[read_lookup(ix,iy)];
    }
  }
  printf("done reading input data\n");

  return 0;
}
