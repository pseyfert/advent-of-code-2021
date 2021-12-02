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

  void apply(const Instruction& i) {
    switch (i.cmd) {
      case Cmd::Forward: {
        horizontal += i.amount;
        depth += aim*i.amount;
        break;
      }
      case Cmd::Down: {
        aim += i.amount;
        break;
      }
      case Cmd::Up: {
        aim -= i.amount;
        break;
      }
    }
  }

  void apply(const std::vector<Instruction>& v) {
    for (const auto& i: v) {
      apply(i);
    }
  }
};
