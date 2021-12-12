#include "internal/game.h"
#include "public/day04.h"

Board::Board(std::array<std::array<uint_fast8_t, 5>, 5> const& data) {
  std::size_t i = 0;
  for (const auto& row : data) {
    for (const auto& cell : row) {
      m_cells[i++] = cell;
    }
  }
}

Board::Board(std::array<std::array<int, 5>, 5> const& data) {
  std::size_t i = 0;
  for (const auto& row : data) {
    for (const auto& cell : row) {
      m_cells[i++] = static_cast<uint_fast8_t>(cell);
    }
  }
}

int Board::board(std::size_t i, std::size_t j) const {
  return static_cast<int>(m_cells[i * 5 + j]);
}

uint_fast8_t& Board::board(std::size_t i, std::size_t j) {
  return m_cells[i * 5 + j];
}

Result Board::play(std::vector<uint_fast8_t> const& drawings) const {
  return play_game(*this, drawings);
}

Result Board::play(std::vector<int> const& drawings) const {
  return play_game(*this, drawings);
}
