#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "FreeImage.h"

int main(int argc, char* argv[]) {

  // call this ONLY when linking with FreeImage as a static library
#ifdef FREEIMAGE_LIB
  FreeImage_Initialise();
#endif // FREEIMAGE_LIB

  // initialize your own FreeImage error handler

  FreeImage_SetOutputMessage(FreeImageErrorHandler);

  // print version & copyright infos

  printf(FreeImage_GetVersion());
  printf("\n");
  printf(FreeImage_GetCopyrightMessage());
  printf("\n");
}