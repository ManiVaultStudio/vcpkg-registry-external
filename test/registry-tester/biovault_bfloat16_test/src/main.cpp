#include "biovault_bfloat16.h"
#include <cmath>

int main()
{
  using biovault::bfloat16_t;
  const bfloat16_t bfloat16_one{ 1 };

  auto f = 0.0f;

  do
  {
    f = std::nextafterf(f, 1.0f);
  } while (bfloat16_t{ 1.0f + f } <= bfloat16_one);

  return bfloat16_t{ 1.0f + f };
}