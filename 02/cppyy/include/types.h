#pragma once
#include <range/v3/algorithm/for_each.hpp>
#if __cplusplus >= 202002L
#include <ranges>
#endif
#include <vector>

enum class Cmd { Forward, Down, Up };

struct Instruction {
  Cmd cmd;
  unsigned amount;
};

struct State {
  unsigned horizontal{0};
  unsigned depth{0};
  int aim{0};

  void apply(const Instruction& i);


#if __cplusplus >= 202002L
  template <std::ranges::input_range T>
#else
  template <typename T>
#endif
  void apply(const T& v) {
    ranges::for_each(v, [this](const Instruction& i) { apply(i); });
  }
};
