/*   driver for fuzz testcases.
     Copyright (C) 2023 David Anderson

     testbuildfuzz.c
     This trivial driver code is hereby placed in
     the public domain for any use without restrictions.

*/
#include <fcntl.h> /* open() O_RDONLY */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#ifndef O_BINARY /* For Windows */
#define O_BINARY 0
#endif

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);

/* So far, just for testing a build */
int main(int argc, char **argv)
{
    int i = 0;
    char *filename = 0;
    const unsigned char *data = 0; 
    size_t size = 0;
    ssize_t ssize = 0;
    int res = 0;
    int fd = -1;
    struct stat statbuf;

    for (i = 1; i< argc; ++i)  {
        if (!strncmp(argv[i],"--testobj=",10)) {
            if (!argv[i][10]) {
                printf("Empty testobj for %s\n",argv[i]);
                exit(EXIT_FAILURE);
            }
            filename = &argv[i][10];
            break;
        }
        if (argv[i][0] == '-') {
            /* ignore other options for now */
            continue;
        }
        break;
    }
    if (!filename) {
        printf("No test object name provided\n");
        exit(EXIT_FAILURE);
    }
    fd = open(filename,O_RDONLY|O_BINARY);
    if (fd < 0 ) {
        printf("Open %s failed\n",filename);
        exit(EXIT_FAILURE);
    }
    res = fstat(fd,&statbuf);
    if (res) {
        printf("fstat %s fd failed\n",filename);
        exit(EXIT_FAILURE);
    }
    size = (size_t)statbuf.st_size;
    data = malloc(size);
    if (!data) {
        printf("malloc %s fd %lu bytes failed\n",filename,
            (unsigned long)size);
        exit(EXIT_FAILURE);
    }
    ssize = read(fd,(void *)data,size);
    if ((unsigned long)ssize != (unsigned long)size) {
        printf("read %s fd %lu bytes readsize %ld failed\n",
            filename, (unsigned long)size,(long)ssize);
        exit(EXIT_FAILURE);
    }
    res = LLVMFuzzerTestOneInput(data,size);
    free((void *)data);
    return res;
}

