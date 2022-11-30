// /opt/nvidia/hpc_sdk/Linux_x86_64/2022/compilers/bin/nvcc -ccbin =gcc-11 --gpu-code sm_75 --gpu-architecture compute_75 hello.cu -o hello && ./hello
// 
// x=0     x=4
// # . . # .  y=0
// #[. . .].
// #[# . .]#
// .[. # .].
// . . # # #  y=4

#include <stdio.h>
#include <numeric>
#include <vector>
#include <array>


static void HandleError( cudaError_t err,
                         const char *file,
                         int line ) {
    if (err != cudaSuccess) {
        printf( "%s in %s at line %d\n", cudaGetErrorString( err ),
                file, line );
        exit( EXIT_FAILURE );
    }
}
#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))

int read(std::array<int, 512>&, std::vector<int>&, char*);

__device__ int idx_lookup(int x, int y) {
  int retval = x + COLS*y;
  if (0 <= retval && retval < COLS*ROWS) {
    return retval;
  } else {
    printf("computed index out of bound %d, %d -> %d\n", x, y, retval);
    return retval;
  }
}

__host__ int idx_lookup_h(int x, int y) {
  return x + COLS*y;
}

__device__ int input_idx_lookup(int* input, int x, int y) {
  if (x>=0 && x < COLS && y >=0 && y< ROWS) {
      return input[idx_lookup(x, y)];
  } else {
    // fingers crossed that the corner piece is "rest of the universe"
    return input[0];
  }
}

__global__ void iter(int* input_, int* output_, int* LUT_) {
  int x_cen = blockIdx.x;
  int y_cen = blockIdx.y;

  /* if (x_cen==0 || x_cen == COLS-1 || y_cen == 0 || y_cen == ROWS-1) { */
  /*   output_[idx_lookup(x_cen, y_cen)] = LUT_[0]; */
  /* } else { */
    int cur =
      (1<<8) * input_idx_lookup(input_, x_cen-1, y_cen-1) +
      (1<<7) * input_idx_lookup(input_, x_cen+0, y_cen-1) +
      (1<<6) * input_idx_lookup(input_, x_cen+1, y_cen-1) +

      (1<<5) * input_idx_lookup(input_, x_cen-1, y_cen+0) +
      (1<<4) * input_idx_lookup(input_, x_cen+0, y_cen+0) +
      (1<<3) * input_idx_lookup(input_, x_cen+1, y_cen+0) +

      (1<<2) * input_idx_lookup(input_, x_cen-1, y_cen+1) +
      (1<<1) * input_idx_lookup(input_, x_cen+0, y_cen+1) +
      (1<<0) * input_idx_lookup(input_, x_cen+1, y_cen+1);
    if (cur >= 512) {
      printf("1<<8 * %d\t 1<<7 * %d\t 1<<6 * %d\t 1<<5 * %d\t 1<<4 * %d\t 1<<3 * %d\t 1<<2 * %d\t 1<<1 * %d\t 1<<0 * %d = %d\n",
      input_idx_lookup(input_, x_cen-1, y_cen-1),
      input_idx_lookup(input_, x_cen+0, y_cen-1),
      input_idx_lookup(input_, x_cen+1, y_cen-1),

      input_idx_lookup(input_, x_cen-1, y_cen+0),
      input_idx_lookup(input_, x_cen+0, y_cen+0),
      input_idx_lookup(input_, x_cen+1, y_cen+0),

      input_idx_lookup(input_, x_cen-1, y_cen+1),
      input_idx_lookup(input_, x_cen+0, y_cen+1),
      input_idx_lookup(input_, x_cen+1, y_cen+1), cur);
    }
    if (LUT_[cur] != 0 && LUT_[cur] != 1) {
      printf("invalid LUT %d\n",LUT_[cur]);
    }
    output_[idx_lookup(x_cen, y_cen)] = LUT_[cur];
  /* } */
}

template <typename T>
void illustrate(T data) {
  for (std::size_t y = 0; y < COLS ; y++) {
    for (std::size_t x = 0; x < ROWS ; x++) {
      if (1==data[idx_lookup_h(x, y)]) {
        printf("#");
      } else if(0==data[idx_lookup_h(x, y)]) {
        printf(".");
      } else {
        printf("!!");
      }
    }
    printf("\n");
  }
}

template <typename T>
int val(T data) {
  int acc = 0;
  for (std::size_t y = 1; y < COLS-1 ; y++) {
    for (std::size_t x = 1; x < ROWS-1 ; x++) {
      acc += data[idx_lookup_h(x, y)];
    }
  }
  return acc;
}

template <std::size_t N>
void lutprint(const std::array<int, N> LUT) {
  for (auto c: LUT) {
    if (c==1) {
      printf("#");
    } else if (c==0) {
      printf(".");
    } else {
      printf("LUT BROKEN\n");
    }
  }
  printf("\n");
}

int main(int argc, char** argv) {
  int *input;
  int *intermediate_a;
  int *intermediate_b;
  int *output;
  int *LUT;
  cudaMalloc((void**)&input, ROWS*COLS*sizeof(int));
  cudaMalloc((void**)&intermediate_a, ROWS*COLS*sizeof(int));
  cudaMalloc((void**)&intermediate_b, ROWS*COLS*sizeof(int));
  cudaMalloc((void**)&output, ROWS*COLS*sizeof(int));
  cudaMalloc((void**)&LUT, 512*sizeof(int));

  std::vector<int> host_image(ROWS*COLS, 0);
  std::array<int, 512> host_LUT;
  /* std::array<int, 512> invalid; */
  /* for (auto& e: invalid) { */
  /*   e = 0; */
  /* } */
  /* invalid[1<<4] = 1; */

  if (read(host_LUT, host_image, argv[1])) {
    printf("???\n");
    return 1;
  };
  lutprint(host_LUT);
  illustrate(host_image);

  HANDLE_ERROR(cudaMemcpy(intermediate_a, host_image.data(), ROWS*COLS*sizeof(int), cudaMemcpyHostToDevice));
  HANDLE_ERROR(cudaMemcpy(LUT, host_LUT.data(), 512*sizeof(int), cudaMemcpyHostToDevice));
  HANDLE_ERROR(cudaDeviceSynchronize());

  for (int i = 0; i < (PADDING-1)/2; ++i) {
    if (i%2 == 0) {
      iter<<<{ROWS, COLS, 1},1>>>(intermediate_a, intermediate_b, LUT);
    } else {
      iter<<<{ROWS, COLS, 1},1>>>(intermediate_b, intermediate_a, LUT);
    }
  }
  cudaDeviceSynchronize();
  printf("CUDA error: %s\n", cudaGetErrorString(cudaGetLastError()));
  if (((PADDING-1)/2 - 1) == 0) {
    HANDLE_ERROR(cudaMemcpy(host_image.data(), intermediate_b, ROWS*COLS*sizeof(int), cudaMemcpyDeviceToHost));
  } else {
    HANDLE_ERROR(cudaMemcpy(host_image.data(), intermediate_a, ROWS*COLS*sizeof(int), cudaMemcpyDeviceToHost));
  }

  illustrate(host_image);

  printf("result %d\n", val(host_image));

  cudaFree(input);
  cudaFree(intermediate_a);
  cudaFree(intermediate_b);
  cudaFree(output);
  cudaFree(LUT);
  return 0;
}
