#pragma once

#include <cstdint>
#include <functional>
#include <glog/logging.h>
#include <iostream>
#include <range/v3/algorithm/all_of.hpp>
#include <range/v3/algorithm/any_of.hpp>
#include <range/v3/algorithm/find_if.hpp>
#include <range/v3/algorithm/for_each.hpp>
#include <range/v3/algorithm/generate.hpp>
#include <range/v3/algorithm/minmax.hpp>
#include <range/v3/numeric/accumulate.hpp>
#include <range/v3/view/chunk.hpp>
#include <range/v3/view/drop.hpp>
#include <range/v3/view/enumerate.hpp>
#include <range/v3/view/indices.hpp>
#include <range/v3/view/stride.hpp>
#include <range/v3/view/transform.hpp>
#include <range/v3/view/zip.hpp>
#include <ranges>
#include "public/day04.h"

template <std::ranges::input_range T>
bool won(T&& flagged);

// template <std::ranges::input_range T>
// void print(T&& flagged) {
//   std::cout << '\n';
//   ranges::for_each(flagged | ranges::view::chunk(5), [](auto&& subrange) {
//     std::cout << '\n';
//     ranges::for_each(subrange, [](uint_fast8_t num) {
//       std::cout << static_cast<int>(num) << ", ";
//     });
//   });
// }

template <std::ranges::input_range T>
Result play_game(Board const& board, T&& drawings) {
  // Assume every number up to once per board.
  // CHECK every board wins eventually.
  std::array<uint_fast8_t, 25> flagged;
  ranges::generate(flagged, []() { return 0; });

  auto win = ranges::find_if(drawings, [&flagged, &board](auto draw) {
    // TODO: adapt won, so this can go to outer scope.
    auto zip = ranges::view::zip(board.m_cells, flagged);
    ranges::for_each(zip, [draw](auto pair) {
      auto& [cellval, flag] = pair;
      if (cellval == draw) {
        flag = 1;
      }
    });
    return won(flagged);
  });

  CHECK(win != end(drawings));

  uint_fast32_t score = ranges::accumulate(
      ranges::view::zip(board.m_cells, flagged), static_cast<uint_fast32_t>(0),
      std::plus<uint_fast32_t>(), [](auto pair) -> uint_fast8_t {
        auto& [cellval, flag] = pair;
        if (flag) {
          return 0;
        } else {
          return cellval;
        }
      });

  return Result{.winning_round = win - begin(drawings), .score = score};
}

template <std::ranges::input_range T1, std::ranges::input_range T2>
Scores play_many_games(T1&& boards, T2&& drawings) {
  auto res = ranges::minmax(
      ranges::view::transform(
          boards,
          [&drawings](auto const& board) {
            return play_board(board, drawings);
          }),
      [](auto const& a, auto const& b) {
        return a.winning_round < b.winning_round;
      });

  return Scores{.part_i = res.min.score, .part_ii = res.max.score};
}

template <std::ranges::input_range T>
bool won(T&& flagged) {
  CHECK_EQ(ranges::distance(flagged), 25);
  // assert flagged is length 25;
  return ranges::any_of(
             flagged | ranges::view::chunk(5),
             [](auto&& row) -> bool {
               return ranges::all_of(row, [](auto const num) -> bool {
                 return static_cast<bool>(num);
               });
             }) ||

         ranges::any_of(ranges::view::indices(5), [flagged](auto offset) {
           return ranges::all_of(
               flagged | ranges::view::drop(offset) | ranges::view::stride(5),
               [](auto const num) -> bool { return static_cast<bool>(num); });
         });
}
