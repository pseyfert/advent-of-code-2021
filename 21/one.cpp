#include <iostream>
#include <tuple>
#include "Vc/Vc"

template <typename T>
struct warner;

struct state {
  int rolls_at_null{-6}; // i.e. before position[0] is reached
  Vc::AVX2::short_v position;
  Vc::AVX2::short_v scores;
};

Vc::AVX2::short_v ten_steps() {
  Vc::AVX2::short_v retval;

  short player_1 = 0;
  short player_2 = 0;
  auto next_dice = 1;
  for (auto i = 0; i < 10; ++i) {
    if ((i%2) == 0) {
      player_1 += next_dice++;
      player_1 += next_dice++;
      player_1 += next_dice++;
    } else {
      player_2 += next_dice++;
      player_2 += next_dice++;
      player_2 += next_dice++;
    }
  }

  for (auto i = 0; i < 12 ; ++i) {
    if ((i%2) == 0) {
      retval[i] = player_1;
    } else {
      retval[i] = player_2;
    }
  }
  return retval;
}

state step(state old_state) {

  state retval;

  retval.scores[0] = old_state.scores[8];
  retval.scores[1] = old_state.scores[9];
  retval.scores[2] = old_state.scores[8];
  retval.scores[3] = old_state.scores[9];
  retval.scores[4] = old_state.scores[8];
  retval.scores[5] = old_state.scores[9];
  retval.scores[6] = old_state.scores[8];
  retval.scores[7] = old_state.scores[9];
  retval.scores[8] = old_state.scores[8];
  retval.scores[9] = old_state.scores[9];
  retval.scores[10] = old_state.scores[8];
  retval.scores[11] = old_state.scores[9];

  retval.position = old_state.position + ten_steps();
  retval.position = ((retval.position - 1) % 10 ) + 1;

  retval.scores += retval.position;                  // 0, 1 get 1 add
  retval.scores += retval.position.shifted(-2);      // 2, 3 get 2 add
  retval.scores += retval.position.shifted(-4);      // 4, 5 get 3 add
  retval.scores += retval.position.shifted(-6);      // 6, 7 get 4 add
  retval.scores += retval.position.shifted(-8);      // 8, 9 get 5 add
  retval.scores += retval.position.shifted(-10);     // 10, 11 get 6 add

  for (auto i = 12; i < retval.scores.size(); ++i) {
    retval.scores[i] = 0;
  }

  retval.rolls_at_null = old_state.rolls_at_null + 30;

  return retval;
}

state init() {
  state retval;
  // example
  // retval.position[0] = 4;
  // retval.position[1] = 8;
  // actual input
  retval.position[0] = 4;
  retval.position[1] = 6;

  auto target_idx = 2;
  auto next_dice = 1;

  while (target_idx<12) {
    retval.position[target_idx] = retval.position[target_idx-2];
    retval.position[target_idx] += next_dice++;
    retval.position[target_idx] += next_dice++;
    retval.position[target_idx] += next_dice++;

    target_idx++;
  }
  retval.position = ((retval.position - 1) % 10 ) + 1;

  retval.scores += retval.position.shifted(2).shifted(-2);
  retval.scores += retval.position.shifted(2).shifted(-4);
  retval.scores += retval.position.shifted(2).shifted(-6);
  retval.scores += retval.position.shifted(2).shifted(-8);
  retval.scores += retval.position.shifted(2).shifted(-10);
  retval.scores += retval.position.shifted(2).shifted(-12);

  for (auto i = 12; i < retval.scores.size(); ++i) {
    retval.scores[i] = 0;
  }

  return retval;
}


int main() {
  // changes to the score repeat after 10 dice rolls (even in tripple rolls).
  // So we can store x[0] = player 1 after their 1st roll
  //                 x[1] = player 2 after their 1st roll
  //                 x[2] = player 1 after their 2nd roll
  //                 x[3] = player 2 after their 2nd roll
  //                 x[4] = player 1 after their 3rd roll
  //                 x[5] = player 2 after their 3rd roll
  //                 x[6] = player 1 after their 4th roll
  //                 x[7] = player 2 after their 4th roll
  //                 x[8] = player 1 after their 5th roll
  //                 x[9] = player 2 after their 5th roll
  //
  // and then add 5 odd turns to elements 0,2,4,6,8
  //      and add 5 even turns to elements 1,3,5,7,9
  //
  // to obtain       x[0] = player 1 after their 6th roll
  //                 x[1] = player 2 after their 6th roll
  //                 x[2] = player 1 after their 7th roll
  //                 x[3] = player 2 after their 7th roll
  //                 x[4] = player 1 after their 8th roll
  //                 x[5] = player 2 after their 8th roll
  //                 x[6] = player 1 after their 9th roll
  //                 x[7] = player 2 after their 9th roll
  //                 x[8] = player 1 after their 10th roll
  //                 x[9] = player 2 after their 10th roll
  //
  // Scores should stay below 1024, i.e. 10 bits are enough (short has 16).
  // in AVX2 we have 16 of them and need 10.
  //
  // To keep track of edge cases, I lean towards keeping x[10], x[11] populated.

  state game_state = init();

  while (game_state.scores.max() < 1000) {
    game_state = step(game_state);
  }

  int result;
  for (auto i = 1; i < 12; ++i) {
    if (game_state.scores[i] >= 1000) {
      int rolls = game_state.rolls_at_null + 3*(i+1);
      int winner = game_state.scores[i];
      int loser = game_state.scores[i-1];
      std::cout << "rolls = " << rolls << '\n';
      std::cout << "winner = " << winner << '\n';
      std::cout << "loser = " << loser << '\n';
      result = rolls*loser;
      break;
    }
  }
  std::cout << game_state.position << std::endl;
  std::cout << game_state.scores << std::endl;
  std::cout << "result = " << result << '\n';
  return 0;
}
