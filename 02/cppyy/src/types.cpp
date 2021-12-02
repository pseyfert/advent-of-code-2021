#include "types.h"

void State::apply(const Instruction& i) {
  switch (i.cmd) {
    case Cmd::Forward: {
      horizontal += i.amount;
      depth += aim * i.amount;
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
