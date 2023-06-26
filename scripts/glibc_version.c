/* From: https://benohead.com/blog/2015/01/28/linux-check-glibc-version/ */

#include <stdio.h>
#include <stdlib.h>
#include <gnu/libc-version.h>

int main(int argc, char *argv[]) {
  printf("glibc version: %s\n", gnu_get_libc_version());
}
