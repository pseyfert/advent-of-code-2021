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
  std::size_t bit_pos = msb(*ranges::max_element(input));
  uint16_t mask{0};
  uint16_t pattern{majority_bit(input, 1 << bit_pos)};
  if (bit_pos == 0) {
    return pattern;
  }
  bit_pos--;
  for (;; bit_pos--) {
    pattern |= majority_bit(filter_stuff(input, pattern, mask), 1 << bit_pos);
    mask |= 1 << bit_pos;
    if (bit_pos == 0) {
      break;
    }
  }
  return pattern;
}

uint16_t gamma(const std::vector<uint16_t>& input) {
  uint16_t pattern{0};
  std::size_t bit_pos = msb(*ranges::max_element(input));
  for (;; bit_pos--) {
    pattern |= majority_bit(input, 1 << bit_pos);
    if (bit_pos == 0) {
      break;
    }
  }
  return pattern;
}

uint16_t epsilon(const std::vector<uint16_t>& input) {
  std::size_t msb_ = msb(*ranges::max_element(input));
  uint16_t pattern{(1 << msb_) - 1};
  uint16_t gamma_ = gamma(input);
  return pattern & ~gamma_;
}

uint16_t most_minority(const std::vector<uint16_t>& input) {
  std::size_t bit_pos = msb(*ranges::max_element(input));
  uint16_t mask{0};
  uint16_t pattern{majority_bit(input, 1 << bit_pos) ^ (1 << bit_pos)};
  if (bit_pos == 0) {
    return pattern;
  }
  bit_pos--;
  for (;; bit_pos--) {
    // TODO: protect against set running empty.
    pattern |= majority_bit(filter_stuff(input, pattern, mask), 1 << bit_pos) ^ (1 << bit_pos);
    mask |= 1 << bit_pos;
    if (bit_pos == 0) {
      break;
    }
  }
  return pattern;
}
