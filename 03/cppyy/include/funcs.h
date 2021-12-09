#pragma once
#include <cstdint>
#include <range/v3/view/filter.hpp>
#include <vector>
#include "interface.h"
#if __cplusplus < 202002L
#error "messed something up"
#endif
#include <bit>
#include <ranges>
#include <type_traits>

template <std::ranges::input_range T>
requires std::is_same_v<typename std::decay_t<T>::value_type, uint16_t>
auto filter_stuff(T&& testables, uint16_t pattern, uint16_t mask) {
  return testables | ranges::view::filter([pattern, mask](const uint16_t tbc) {
           return accept(tbc, pattern, mask);
         });
}

template <std::ranges::input_range T>
// requires std::is_same_v<typename std::decay_t<T>::value_type, uint16_t>
auto majority_bit(T&& testables, const uint16_t single_bit) {
  if (std::popcount(single_bit) != 1) {
    // std::cout << "BIG ISSUE\n";
  }
  if (ranges::distance(testables) == 0) {
    // std::cout << "BIG ISSUE\n";
  }
  const std::size_t count = ranges::distance(testables);
  // even? → >= count/2 = (count+1)/2
  // odd?  → > count/2 or >= (count+1)/2
  const std::size_t needs = (count + 1) / 2;
  const std::size_t have_ones = ranges::distance(
      testables | ranges::view::filter([single_bit](const uint16_t tbc) {
        return single_bit & tbc;
      }));
  if (have_ones >= needs) {
    return single_bit;
  }
  return (decltype(single_bit))0;
}

std::size_t msb(const uint16_t number);
