#include <array>
#include <range/v3/algorithm/max_element.hpp>
#include <range/v3/range/conversion.hpp>
#include <utility>
#include <vector>
#include "funcs.h"
#include "gtest/gtest.h"

TEST(logic, accept) {
  EXPECT_TRUE(accept(0b00011, 0b00000, 0b11100));
  EXPECT_TRUE(accept(0b00000, 0b00000, 0b11100));
  EXPECT_TRUE(accept(0b00010, 0b00000, 0b11100));
  EXPECT_TRUE(accept(0b00001, 0b00000, 0b11100));
  EXPECT_TRUE(accept(0b11111, 0b11100, 0b11100));
  EXPECT_TRUE(accept(0b11111, 0b11111, 0b10100));
  EXPECT_FALSE(accept(0b00111, 0b00000, 0b11100));
  EXPECT_FALSE(accept(0b01000, 0b00000, 0b11100));
  EXPECT_FALSE(accept(0b00010, 0b00000, 0b10110));
  EXPECT_FALSE(accept(0b00001, 0b00000, 0b00001));
  EXPECT_FALSE(accept(0b11111, 0b01100, 0b11100));
  EXPECT_FALSE(accept(0b11011, 0b11111, 0b11100));
}

TEST(logic, accept_range) {
  std::vector<uint16_t> v{1, 2, 3, 4, 5, 6, 7, 8};
  std::array<uint16_t, 4> a{2, 4, 6, 8};

  auto v_filt = filter_stuff(std::as_const(v), 2, 1) | ranges::to_vector;
  auto a_filt = filter_stuff(std::as_const(a), 2, 1) | ranges::to_vector;

  EXPECT_EQ(a_filt.size(), 4);
  EXPECT_EQ(v_filt.size(), 4);
  EXPECT_EQ(a_filt[0], 2);
  EXPECT_EQ(a_filt[1], 4);
  EXPECT_EQ(a_filt[2], 6);
  EXPECT_EQ(a_filt[3], 8);
  EXPECT_EQ(v_filt[0], 2);
  EXPECT_EQ(v_filt[1], 4);
  EXPECT_EQ(v_filt[2], 6);
  EXPECT_EQ(v_filt[3], 8);
}

TEST(logic, bits) {
  EXPECT_EQ(5, msb(1 << 5));
  EXPECT_EQ(0, msb(1 << 0));
  std::vector<uint16_t> data{0b10101, 0b10101, 0b10101,
                             0b10101, 0b11111, 0b00000};
  EXPECT_EQ(0b10000, 1 << msb(*ranges::max_element(data)));
  EXPECT_EQ(majority_bit(data, 0b10000), 0b10000);
  EXPECT_EQ(majority_bit(data, 0b01000), 0b00000);
  EXPECT_EQ(majority_bit(data, 0b00100), 0b00100);
  EXPECT_EQ(majority_bit(data, 0b00010), 0b00000);
  EXPECT_EQ(majority_bit(data, 0b00001), 0b00001);

  EXPECT_EQ(most_majority(data), 0b10101);
}

TEST(logic, filter) {
  std::vector<uint16_t> data{0b10101, 0b10101, 0b10101,
                             0b10101, 0b11111, 0b00000};

  auto filtered =
      filter_stuff(data, most_majority(data), 0b10000) | ranges::to_vector;
  EXPECT_EQ(filtered.size(), 5);
  filtered = filter_stuff(filtered, most_majority(filtered), 0b01000) |
             ranges::to_vector;
  EXPECT_EQ(filtered.size(), 4);
  filtered =
      filter_stuff(data, most_majority(filtered), 0b11000) | ranges::to_vector;
  EXPECT_EQ(filtered.size(), 4);
  for (const auto p : filtered) {
    EXPECT_EQ(p, 0b10101);
  }
}
