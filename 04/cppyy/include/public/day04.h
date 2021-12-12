#pragma once

#include <array>
#include <cstdint>
#include <vector>

struct Result {
  std::size_t winning_round;

  // upper bound:
  // 20 * 100 * 100
  //  │    │     └── Last drawn number
  //  │    └──────── Maximal digit value
  //  └───────────── Unmarked cells
  uint_fast32_t score;
};

struct Scores {
  uint_fast32_t part_i;
  uint_fast32_t part_ii;
};

class Board {
 public:
  Board(std::array<std::array<uint_fast8_t, 5>, 5> const& data);
  Board(std::array<std::array<int, 5>, 5> const& data);

  int board(std::size_t i, std::size_t j) const;
  uint_fast8_t& board(std::size_t i, std::size_t j);

  Result play(std::vector<uint_fast8_t> const& drawings) const;
  Result play(std::vector<int> const& drawings) const;

//  private:
  std::array<uint_fast8_t, 25> m_cells;
};
