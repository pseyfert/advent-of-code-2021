#include "gtest/gtest.h"
#include "internal/game.h"

TEST(winning_conditions, simple) {
  std::array<uint_fast8_t, 25> flagged_1{
      // clang-format off
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      1, 1, 1, 1, 1,
      // clang-format on
  };
  std::array<uint_fast8_t, 25> flagged_2{
      // clang-format off
      1, 1, 1, 1, 1,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      // clang-format on
  };
  std::array<uint_fast8_t, 25> flagged_3{
      // clang-format off
      1, 1, 0, 1, 1,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      // clang-format on
  };
  std::array<uint_fast8_t, 25> flagged_4{
      // clang-format off
      1, 1, 0, 1, 1,
      0, 0, 0, 1, 1,
      0, 0, 1, 0, 1,
      0, 1, 0, 1, 1,
      0, 0, 0, 0, 1,
      // clang-format on
  };
  std::array<uint_fast8_t, 25> flagged_5{
      // clang-format off
      1, 1, 0, 1, 1,
      0, 1, 0, 1, 1,
      0, 1, 1, 0, 1,
      0, 1, 0, 1, 0,
      0, 1, 0, 0, 1,
      // clang-format on
  };
  EXPECT_TRUE(won(flagged_1));
  EXPECT_TRUE(won(flagged_2));
  EXPECT_FALSE(won(flagged_3));
  EXPECT_TRUE(won(flagged_4));
  EXPECT_TRUE(won(flagged_5));
}

TEST(games, quick) {
  Board b{std::array{
      std::array{1, 2, 3, 4, 5},
      std::array{9, 9, 9, 9, 9},
      std::array{9, 9, 9, 9, 9},
      std::array{9, 9, 9, 9, 9},
      std::array{9, 9, 9, 9, 9},
  }};

  auto r = play_game(b, std::array{1, 2, 3, 4, 5});
  EXPECT_EQ(r.winning_round, 4);
  // r = play_game(b, std::array{8, 2, 3, 4, 5});
  // EXPECT_EQ(r.winning_round, 6);
}
