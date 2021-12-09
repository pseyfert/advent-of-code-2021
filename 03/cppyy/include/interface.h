#pragma once
#include <cstdint>
#include <range/v3/view/filter.hpp>
#include <vector>

bool accept(uint16_t tbc, uint16_t search_pattern, uint16_t mask);

uint16_t most_majority(const std::vector<uint16_t>&);

uint16_t most_minority(const std::vector<uint16_t>&);

uint16_t epsilon(const std::vector<uint16_t>&);

uint16_t gamma(const std::vector<uint16_t>&);
