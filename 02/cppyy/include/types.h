#pragma once
#include <range/v3/algorithm/for_each.hpp>
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

  template <typename T>
  void apply(const T& v) {
    ranges::for_each(v, [this](const Instruction& i) { apply(i); });
  }
};
