/*  See 'man feature_test_macros' and 'man open'
    as we attempt to allow creating a big
    file even on a 32-bit-pointer system.  
    Which will really only work on Linux
    using GNU libc */
#define _FILE_OFFSET_BITS 64

#include <sys/types.h> /* open */
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h> /* close read write */
#include <string.h> /* memcpy */
#include <stdlib.h>  /* exit */
#include <stdio.h>  /* printf etc */
#include <errno.h> 


#ifndef O_BINARY
#define O_BINARY 0
#endif /* O_BINARY */


const char *path = "./bigobject";

/* The inputobj is supposed to be small. */
const char *inputobj = "./hello";

int ifd = 0;
int ofd = 0;

#define ALIGNROOM 32

static void
seekvalid(off_t targetoff,off_t resultoff,
    int myerrno,
    int direction,
    const char *msg,
    const char *path)
{
    if (resultoff == (off_t)-1) {
        char *directionstr = "SEEK_SET";
        switch (direction) {
        case SEEK_SET:
            break;
        case SEEK_END:
            directionstr = "SEEK_END";
            break;
        case SEEK_CUR:
            directionstr = "SEEK_CUR";
            break;
        default:
            directionstr = "UNKNOWN-SEEK-TYPE";
        }

        printf(" object %s %s %s (errno %d) %s\n",
            path,
            msg,
            directionstr,
            myerrno,
            strerror(myerrno));
        close(ifd);
        close(ofd);
        exit(1);
    }
}

static void
rwvalid(ssize_t len,ssize_t result,int myerrno,
    const char* msg,
    const char*path)
{
    if (result == -1) {
        int myerrno = errno;
        printf("object %s %s (errno %d) %s\n",
            path,
            msg,
            myerrno,
            strerror(myerrno));
        close(ifd);
        close(ofd);
        exit(1);
    }
    if (len != result) {
        printf("object %s %s failed, short %ld %lu\n",
            path,
            msg,
            (long)len,(unsigned long)result);
        close(ifd);
        close(ofd);
        exit(1);
    }

}

static void
copy_section_table(int ifd,int ofd,void *indata,
    off_t inputsize,off_t finalsize)
{
    off_t shoff = 0x2268;
    ssize_t shsize = 0x22*0x40;
    off_t targetoff = finalsize - shsize - ALIGNROOM  ;
    off_t ioffset = 0;
    off_t ooffset = 0;
    void * shptr = 0;
    ssize_t amountwritten = 0;
    off_t fieldlength = 8;
   
    targetoff &= ~((off_t)0xf);
    ooffset = lseek(ofd,targetoff,SEEK_SET);
    seekvalid(targetoff,ooffset,errno,SEEK_SET,
        "seek to section table",path);
    shptr = (char *)indata + shoff;
    amountwritten = write(ofd,shptr,shsize);
    rwvalid(shsize,amountwritten,errno,
        "write section table",path);
    /*  Zero out the bytes in original section table
        to guarantee we are reading the new copy. */
    memset(shptr,0,shsize); 
    ooffset = lseek(ofd,shoff,SEEK_SET);
    seekvalid(targetoff,ooffset,errno,SEEK_SET,
        "seek to original section table to zero it",path);
    amountwritten = write(ofd,shptr,shsize);
    rwvalid(shsize,amountwritten,errno,
        "write zeros in orig section table location",path);

    /* Offset of the e_shoff field, length 8 */
    shoff = 40;
    ooffset = lseek(ofd,shoff,SEEK_SET);
    seekvalid(shoff,ooffset,errno,SEEK_SET,
        "seek to location of e_shoff field",path);

    /*  Only works if our endianness matches the object */
    amountwritten = write(ofd,&targetoff,fieldlength);
    rwvalid(fieldlength,amountwritten,errno,
        "write new section table offset into e_shoff",path);
}

int 
main(int argc, char *argv[])
{
    off_t  ioffset = 0;
    off_t  inputsize = 0;
    void * indata = 0;
    ssize_t amountread = 0;
    ssize_t amountwritten = 0;
    off_t   newsize =  100000;

    if (argc == 2) {
         char * sz = argv[1];
         char *endptr = 0;
         long long v = 0;
         
         errno = 0;
         v = strtoll(sz,&endptr,0);
         if (errno == ERANGE) {
            printf("Expected target bigobject file size, not: %s\n",sz);
            printf("Giving up.\n");
            exit(1);
         }
         if (v < newsize) {
            printf("Expected target bigobject file size %lld "
                "pointlessly small.\n",v);
            printf("Giving up.\n");
            exit(1);
         }
         newsize = (off_t)v;
         
    }

    ifd = open(inputobj,O_RDONLY|O_BINARY);
    if (ifd == -1) {
        int myerrno = errno;
        printf("Open of input object %s failed (errno %d) %s\n",
            inputobj,
            myerrno,
            strerror(myerrno));
        exit(1);
    }
    /* We do not specify O_EXCL.  */
    ofd = open(path,O_CREAT|O_WRONLY|O_BINARY,S_IRWXU|S_IRWXG|S_IRWXO);
    if (ofd == -1) {
        int myerrno = errno;
        printf("Open/create of object %s failed (errno %d) %s\n",
            path,
            myerrno,
            strerror(myerrno));
        close(ifd);
        exit(1);
    }
    /* printf("Output %s fd %d\n",path,ofd); */
    ioffset = lseek(ifd,0,SEEK_END);
    seekvalid(0,ioffset,errno,SEEK_END,
        "seek to end of input file ",inputobj);

    inputsize = ioffset; 
    ioffset = lseek(ifd,0,SEEK_SET);
    seekvalid(0,ioffset,errno,SEEK_SET,
        "seek to 0byte of input ",inputobj);

    indata = malloc(inputsize);
    if (!indata) {
        printf("malloc object %s failed (len %lu)\n",
            inputobj,(unsigned long)inputsize);
        close(ifd);
        close(ofd);
        exit(1);
    }

    amountread = read(ifd,indata,inputsize);
    rwvalid(inputsize,amountread,errno,
        "Reading input object entire text",
        inputobj);
    amountwritten = write(ofd,indata,inputsize);
    rwvalid(inputsize,amountwritten,errno,
        "Write input object entire text to outputfile",
        path);

    ioffset = lseek(ofd,newsize,SEEK_SET);
    seekvalid(newsize,ioffset,errno,SEEK_SET,
        "seek to new end of big output table",path);

    ioffset = lseek(ofd,newsize-1,SEEK_SET);
    seekvalid(newsize,ioffset,errno,SEEK_SET,
        "seek to just before end of big output table",path);
    amountwritten = write(ofd,indata,1);
    rwvalid(1,amountwritten,errno,
        "Write one byte to end of outputfile",
        path);
    copy_section_table(ifd,ofd,indata,inputsize,newsize);

    close(ifd);
    close(ofd);
    return 0;
}
