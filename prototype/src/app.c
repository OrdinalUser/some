#include "some.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[])
{
    // exclude the program name and pass arguments over to lib
    some(argc-1, (const char**)argv+1);
}