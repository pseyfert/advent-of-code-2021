#include "funcs.h"
#include <range/v3/algorithm/max_element.hpp>
#include <range/v3/view/indices.hpp>

#include <iostream>

bool accept(uint16_t tbc, uint16_t search_pattern, uint16_t mask) {
  return mask == (mask & ~(tbc ^ search_pattern));
}

std::size_t msb(const uint16_t number) {
  for (std::size_t i : ranges::views::indices(16)) {
    if ((1 << i) > number) {
      return i - 1;
    }
  }
  return 16;
}

uint16_t most_majority(const std::vector<uint16_t>& input) {
  uint16_t testbit = 1 << msb(*ranges::max_element(input));
  uint16_t mask{0};
  uint16_t pattern{majority_bit(input, testbit)};
  testbit = testbit >> 1;
  for (; testbit != 0; testbit = testbit >> 1) {
    pattern |= majority_bit(filter_stuff(input, pattern, mask), testbit);
    mask |= testbit;
  }
  return pattern;
}

uint16_t gamma(const std::vector<uint16_t>& input) {
  uint16_t pattern{0};
  uint16_t testbit = 1 << msb(*ranges::max_element(input));
  for (; testbit != 0; testbit = testbit >> 1) {
    pattern |= majority_bit(input, testbit);
  }
  return pattern;
}

uint16_t epsilon(const std::vector<uint16_t>& input) {
  std::size_t msb_ = msb(*ranges::max_element(input));
  uint16_t pattern{(1 << 1 + msb_) - 1};
  uint16_t gamma_ = gamma(input);
  return pattern & ~gamma_;
}

uint16_t most_minority(const std::vector<uint16_t>& input) {
  uint16_t testbit = 1 << msb(*ranges::max_element(input));
  uint16_t mask{0};
  uint16_t pattern{majority_bit(input, testbit) ^ testbit};
  testbit = testbit >> 1;
  for (; testbit != 0; testbit = testbit >> 1) {
    // TODO: protect against set running empty.
    if (ranges::distance(filter_stuff(input, pattern, mask)) == 0) {
      break;
    }
    pattern |=
        majority_bit(filter_stuff(input, pattern, mask), testbit) ^ testbit;
    mask |= testbit;
  }
  return pattern;
}
