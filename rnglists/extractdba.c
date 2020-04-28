/* $Header: /home/davea/misc/palm/RCS/extractdba.c,v 1.19 2006/09/29 17:03:22 davea Exp $  
A program to read in a Palm calendar data base 
in 'dba' form and output in a different form.

Copyright 2005,2006 David Anderson, davea42 'at'
earthlink -dot- net
Permission is hereby granted to copy or use this code for
any purpose, without restriction.

Build with 
	cc -g -gdwarf-2 extractdba.c -o extractdba;
Get the .dba file from windows and name it 'cal.dba' in the
current directory.
Run with
	./extractdba >out.txt
The palm-importable file  is 'out.txt' and it uses 'return'
not 'newline' as line-delimiters to match Mac OSX.
Only tested on ia32 Linux (expect to have to change
things a little to get it to work on x86-64 or other 64-bit cpu).

If the 'run' machine is a different endianness than the
palm machine, the above may print really strange dates (like 1961).
In that case, try
        ./extractdba -s >out.txt
which simply means to apply 'byte swapping' code built
into extractdba.  [Feature added September, 2006]

If the times are off by a few hours there may be a disagreement
between the machines as to what time zone you are in.
Right now that time-zone issue has no built-in fix.

The .dba file from Windows was copied to a CD and 
carried to Linux. This app
was written in C, run on Linux, and the result then
mailed to a Mac and imported into the the Palm desktop app calendar.

From the Palm app on a Windows ME laptop, the only possible
output format was .dba form.  But there was no way to read this
on a Mac running Palm software. I wanted to move the data
from Windows to Mac (about 2400 entries).

The 'dba' form is undocumented.

The Mac Palm app can, however, read tab-field-delimited,
'return' separarated records though.

Some enterprising folks have attempted to document the .dba
form, but their documents did not match what I found sufficiently
well to be reassuring.

I noticed a heuristic to make the conversion.
Simply look for the  magic bytes (see d: thru g: below)
and if that pattern is found, presume it is a valid entry. 

Presently prints the output for Mac on stdout, and
another form on stderr for a human to look at (for debugging).

--------------defects:

This does nothing at all about repeated items: such
info is just lost here.
What is here was sufficient for me.

Several routimes here (including ctime) use static buffers
to return strings, so DO NOT call multiple routines
in a single printf. After every such call do an immediate
printf.    


----------------details
Entry finding is a heuristic.  
Format of a date item is
  a:	4byte: start time
  b:	4 byte value 1
  c:	4 byte end time
  d:    byte value 5, followed by 5 zero bytes
  e:	2 bytes of zero bytes
  f:	byte: length of string
  g:	bytes of the string described by the length.

The app looks for the magic '5 followed by  5 zero bytes',
followed by 2 ignored bytes, then a 'String'.

Strings are:
	byte: length of string
	followed by 'length' characters (say minimum 3)
	which should be ordinary printable characters.
	
Format of a date item is
	4byte: start time
	4 byte value 1
	4 byte end time
	byte value 5, followed by 5 zero bytes
	2 bytes of zero bytes
	byte: length of string
	'length' of the string described.

	
*/

#include <stdio.h>
#include <time.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <ctype.h>


static FILE *input;
static char *filename = "cal.dba";
static int do_swap_bytes;

/* Return pointer past the special string, or 0 */
static char *
matches5nul(char *v)
{
	int i;
	if(*v != 5)
		return 0;
	++v;
	for(i = 0; i < 5; ++i,++v) {
	   if(*v != 0) {
		return 0;
	   }
		
	}
	return v; /* OK! is our special string. */
}

#define BUFFERSZ 100
/* The STRLEN is a heuristic. With it, too-long entries are lost. */ 
#define STRLEN 50 /* must be strictly less than BUFFERSZ */
static char lbuf[BUFFERSZ];

/* Return 1 if it's a 'normal' printable character.
   Used to validate something purporting to be a string.
*/
static int validchar(char *cp)
{
	int c = (int)*cp;
	if(isprint(c))
		return 1;
	if(isblank(c))
		return 1;
	return 0;
}

/* Return 1 if it's  'String' (see documentation above).
   Used to validate something purporting to be a string.
*/
static char *
validstring(char *v)
{
	int slen = *v;
	int i;
	if(slen < 2 || slen > STRLEN) {
		return 0;
	}
	v++;
	for(i = 0; i < slen; ++i,++v) {
	    if(!validchar(v)) {
		return 0;
	    }
	    lbuf[i] = *v;
	}
	lbuf[i] = 0;
	return lbuf;
}

/* ctime() adds a newline. remove it for convenience. */
static char datebuf[100];
static char *
trim(char *in)
{
	char *cp = in;
	char *op = &datebuf[0];
	for(  ; *cp && *cp != '\n'; ++cp, ++op) {
		*op = *cp;
	}
	*op = 0;
	return datebuf;
}

char *month[] = {
	"January","February", "March",
	"April", "May", "June", 
	"July", "August", "September",
	"October", "November", "December"
};

static char datefmt[100];
/* write out a date Palm can import. */
static char *
formatday(struct tm *d)
{
	snprintf(datefmt,sizeof(datefmt), "%s %d, %d",
		month[d->tm_mon],
		d->tm_mday,
		d->tm_year + 1900);

	return datefmt;
}
/* write out a duration Palm can import. */
static char *
formatduration(struct tm *s,struct tm *e)
{
	unsigned start = s->tm_min + s->tm_hour*60;
	unsigned end = e->tm_min + e->tm_hour*60;
	unsigned durminutes = end - start;
	unsigned hrs = durminutes/60;
	unsigned mins = durminutes%60;
	snprintf(datefmt,sizeof(datefmt),"%d:%02d",hrs,mins);
	return datefmt;
}
/* write out a time Palm can import. */
static char *
formattime(struct tm *d)
{
	int hr12 = d->tm_hour;
	char *modifier = "AM";
	if(hr12 > 11) {
		modifier = "PM";
	}
	if(hr12 > 12) {
		hr12 -= 12;
	}
	if(hr12 == 0) {
		hr12 = 12; /* 12:xx AM */
	}
        snprintf(datefmt,sizeof(datefmt), "%d:%02d %s",
                hr12,
                d->tm_min,modifier);

        return datefmt;
}

/* Extract the bytes of a unix-style seconds-since-1970
   into a time_t.
   That a simple memcpy makes the bytes match right
   is rather convenient, but not guaranteed to work
   for 64-bit cpus or for arbitrary endianness.
   But it will likely work.
*/
static void
make_date(char *d_in, time_t *out)
{
    if(do_swap_bytes) {
	char *tout = (char *)out;
	tout[3] = d_in[0];
	tout[2] = d_in[1];
	tout[1] = d_in[2];
	tout[0] = d_in[3];
    } else {
	memcpy(out,d_in,4);
    }
    return;
}
#define ENDOFF -12
#define STARTOFF -20

/* Figure out what bytes are  entries of interest
   and output them.
   Ignore other  bytes that don't match the pattern.
*/
static void
look_for_entries(char *data,size_t len)
{
	size_t curoff = 0;
	char * curp = data;
	/* We must not match too close to end. So ignore end. */
	len -= 7;
	int outct = 0;

	for( ; curoff < len; ++curoff,++curp) {
		char *nulend = matches5nul(curp); 
		char *beginstr = 0;
		char *name =0;
		char *enddate = 0;
		char *stdate = 0;
		time_t start = 0;
		time_t end = 0;
		struct tm startd;
		struct tm endd;

		if(!nulend) {
			continue;
		}
		beginstr = nulend+2;
		name = validstring(beginstr);
		if(!name) {
			continue;
		}
	        enddate = beginstr + ENDOFF;
		stdate = beginstr + STARTOFF;

		make_date(enddate,&end);
		make_date(stdate,&start);
		
		localtime_r(&start,&startd);
		localtime_r(&end,&endd);
		
		/*printf("start 0x%08x end 0x%08x\n",
			start,end); */
			
		printf("%s\t\t", name);
		printf ("%s\t",
			formatday(&startd));
		printf ("%s\t",
			formattime(&startd));
		printf ("%s\t",
			formatduration(&startd,&endd));
		printf("\t\t");
		printf("Not Private\r");
		++outct;

		fprintf(stderr,"%s",name);
		fprintf(stderr," %s",trim(ctime(&start)));
		fprintf(stderr," %s\n",trim(ctime(&end)));

	}
	fprintf(stderr,"%d total records\n",outct);

}

int 
main(int argc,char **argv)
{
	size_t size = 0;
	long i;
	struct stat buf;
	int myfd = -1;
	char *maparea;
	time_t curtime;
	time_t latetime;


	if(argc > 1) {
	   if(0 == strcmp(argv[1],"-s")) {
		do_swap_bytes =1;
	   }
        }

	i = stat(filename,&buf);
	if(i) {
		fprintf(stderr,"stat failed\n");
		exit(1);
	}
	
	size = buf.st_size;
 	/*printf("File size %ld bytes\n",(long)size) */
	
	myfd = open(filename,O_RDONLY);
	if(myfd < 3) {
	   fprintf(stderr,"open failed\n");
	   exit(2);
	}

	maparea = (char *)mmap(0,size,PROT_READ,MAP_PRIVATE,myfd,0);
        if((void *)maparea == MAP_FAILED) {
		fprintf(stderr,"mmap failed\n");
		exit(3);
        }	

	look_for_entries(maparea,size);
	munmap(maparea,size);
	close(myfd);
	return 0;
}
