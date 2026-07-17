#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "FreeImage.h"

void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const char *message) {
	printf("\n*** "); 
	if(fif != FIF_UNKNOWN) {
		printf("%s Format\n", FreeImage_GetFormatFromFIF(fif));
	}
	printf(message);
	printf(" ***\n");
  }

int main(int argc, char* argv[]) {

  // call this ONLY when linking with FreeImage as a static library
#ifdef FREEIMAGE_LIB
  FreeImage_Initialise();
#endif // FREEIMAGE_LIB

  // initialize your own FreeImage error handler

  FreeImage_SetOutputMessage(FreeImageErrorHandler);

  // print version & copyright infos

  printf("Version: %s \n",FreeImage_GetVersion());
  printf("Copyright: %s \n",FreeImage_GetCopyrightMessage());
}