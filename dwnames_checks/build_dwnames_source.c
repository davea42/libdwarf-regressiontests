/*
    Copyright 2023 David Anderson. All rights reserved.

*/
/*  Used by regession tests: DWARFTESTS.sh

   Using options does exactly one of 3 things: 

   (A) --print-found
   Print simple list of the DW_TAG_etc entries from dwarf.h
   for a human reader.  Just for debugging.

   (B) --generate-func-array
   Generate an array of function pointers to the dwarf_get*_name
   functions (one per DW_AT etc prefix).
   (C code). The output to be placed in this source file.

   (C) --run-self-test
   Run a self-test of all the dwarf_get_*name() functions
   using the arrays created by earlier runs.
   For this part the self-test code here will be calling libdwarf.

   Parts A and B, are not run during testing,
   just part C is the self-test proper.
   
*/


#ifdef _WIN32
#define _CRT_SECURE_NO_WARNINGS
#endif /* _WIN32 */

#include <stddef.h> /* NULL size_t */
#include <ctype.h>  /* isspace() */
#include <errno.h>  /* errno */
#include <stdio.h>  /* fgets() fprintf() printf() sscanf() */
#include <stdlib.h> /* exit() qsort() strtoul() */
#include <string.h> /* strchr() strcmp() strcpy() strlen()
    strncmp() size_t */
#include "dwarf.h"
#include "libdwarf.h"


/*  test_dwnames.c
    Reads libdwarf.h and for each DW_AT_* (for all such
    defines calls the dwarf_get_AT_name or equivalent
    and verifies the result string matches expectations.
    (such as the TAG name string for a particular tag).

*/

static int GenerateOneSet(int tf_value);
#ifdef TRACE_ARRAY
static void PrintArray(void);
#endif /* TRACE_ARRAY */
static int is_skippable_line(char *pLine);
static int ParseDefinitionsAndWriteOutput(void);

/* We don't need really long lines: the input file is simple. */
#define MAX_LINE_SIZE 1000
/*  We don't need a variable array size,
    it just has to be big enough. */
#define GROUP_ARRAY_SIZE 400
#define FALSE     0
#define TRUE      1

#define MAX_NAME_LEN 64

static const char *part1[] = {
"/*  Copyright (c) 2023 David Anderson",
"    ",
"    This test code is hereby placed in the PUBLIC DOMAIN",
"    for anyone to copy/alter/use in any way.",
"",
"*/",
"",
"#include <config.h>",
"#include <string.h> /* for strcmp */",
"#include <stdlib.h> /* for exit() */",
"#include <stdio.h> /* for printf() */",
"#include <dwarf.h>",
"#include <libdwarf.h>",
"   ",
"static long checkcount = 0; ",
"   ",
"static void",
"check_valid(int res,",
"    const char *funname,",
"    const char *expectedname,",
"    int         value,",
"    const char *returnedname)",
"{",
"    ++checkcount; ",
"    if (res != DW_DLV_OK) {",
"        printf(\"FAIL call %s res %d (%s %d %s)\\n\",",
"            funname,res,expectedname,value,returnedname);",
"        exit(EXIT_FAILURE);",
"    }",
"    if (strcmp(expectedname,returnedname)) {",
"        printf(\"FAIL call \\\"%s\\\"  expected \\\"%s\\\" \"",
"            \"for %d but got \\\"%s\\\"\\n\",",
"            funname,expectedname,value,returnedname);",
"        exit(EXIT_FAILURE);",
"    }",
"}",
" ",
"static void",
"run_tests(void) {",
"    int res = 0;",
"    const char *ret_name = 0;",
0
};

static const char *part3[] = {
"}",
"",
"int main(void) {",
"    run_tests();",
"    printf(\"PASS dwnames_all, %ld checks\\n\",checkcount);",
"    return 0;",
"}",
0
};

static void
printpartlines(const char *part[])
{
    const char **partline =  part;

    for ( ; *partline ; partline++) {
        printf("%s\n",*partline);
    }
}



/* To store entries from dwarf.h */
typedef struct {
    char     ad_name[MAX_NAME_LEN];       /* short name */
    char     ad_prefixname[MAX_NAME_LEN]; /* DW_AT or the like */
    unsigned ad_value; /* value */
    /* Original spot in array.   Lets us guarantee a stable sort. */
    unsigned ad_original_position;
} array_data;

/*  A group_array is a grouping from dwarf.h.
    All the TAGs are one group, all the
    FORMs are another group, and so on. */
static array_data group_array[GROUP_ARRAY_SIZE];
static unsigned group_array_count = 0;

typedef int (*compfn)(const void *,const void *);
static int Compare(array_data *,array_data *);

static const char *prefix_root = "DW_";
static const unsigned prefix_root_len = 3;

/* f_dwarf_in is the input dwarf.h. */
static FILE *f_dwarf_in;

/* Size unchecked, but large enough. */
static char prefix[200] = "";

static const char *usage[] = {
    "Usage: gennames <options>",
    "    -i  <path/src/lib/libdwarf>",
    "    --print-found",
    "    --generate-func_array",
    "    --generate-self-test",
    "    --run-self-test",
    "",
};

static void
reset_group_array(void)
{
     group_array_count = 0;
     memset(group_array,0,sizeof(array_data)*GROUP_ARRAY_SIZE);
}

void
safe_strcpy(char *out, size_t outlen,
    const char *in_s, size_t inlen)
{
    size_t      full_inlen = inlen+1;
    char       *cpo = 0;
    const char *cpi= 0;
    const char *cpiend = 0;

    if (full_inlen >= outlen) {
        if (!outlen) {
            return;
        }
        cpo = out;
        cpi= in_s;
        cpiend = in_s +(outlen-1);
    } else {
        /*  If outlen is very large
            strncpy is very wasteful. */
        cpo = out;
        cpi= in_s;
        cpiend = in_s +inlen;
    }
    for ( ; *cpi && cpi < cpiend ; ++cpo, ++cpi) {
        *cpo = *cpi;
    }
    *cpo = 0;
}



/*   A default dir, useful for initial testing */
static char *input_dir = "/home/davea/dwarf/code/src/lib/libdwarf";

static void
print_usage_message(const char *options[])
{
    int index;
    for (index = 0; *options[index]; ++index) {
        printf("%s\n",options[index]);
    }
}

int print_found_content = TRUE;
int generate_func_array = FALSE;
int generate_self_test = FALSE;

static void
set_all_false(void)
{
    print_found_content = FALSE;
    generate_func_array = FALSE;
    generate_self_test = FALSE;
}


/* process arguments */
static void
process_args(int argc, char *argv[])
{
    int i = 0;

    for(i = 1; i < argc;++i) {
        if (!strcmp(argv[i],"-i")) {
            ++i;
            input_dir = argv[i];
            continue;
        } else if (!strcmp(argv[i],"--generate-self-test")) {
            set_all_false();
            generate_self_test = TRUE;
        } else if (!strcmp(argv[i],"--suppress-de-alloc-tree")) {
            /*  Do nothing, this is irrelevant to the test
                but it is allowed */
        } else {
            print_usage_message(usage);
            exit(EXIT_FAILURE);
        }
    }
    if (!input_dir) {
        printf("FAIL. directory of dwarf.h not specified.");
        exit(EXIT_FAILURE);
    }
    if (i != argc) {
        print_usage_message(usage);
        exit(EXIT_FAILURE);
    }
}

/*  Ends in 0,0 entry */
typedef int( *getnamefuncptr)(unsigned int, const char **);

struct funcpointerarray_s {
   const char *fp_prefix;
   const char *fp_name;
} funcpointerarray[] =
{
{ "DW_TAG","dwarf_get_TAG_name"},
{ "DW_children","dwarf_get_children_name"},
{ "DW_FORM","dwarf_get_FORM_name"},
{ "DW_AT","dwarf_get_AT_name"},
{ "DW_OP","dwarf_get_OP_name"},
{ "DW_ATE","dwarf_get_ATE_name"},
{ "DW_DEFAULTED","dwarf_get_DEFAULTED_name"},
{ "DW_IDX","dwarf_get_IDX_name"},
{ "DW_LLEX","dwarf_get_LLEX_name"},
{ "DW_LLE","dwarf_get_LLE_name"},
{ "DW_RLE","dwarf_get_RLE_name"},
{ "DW_GNUIVIS","dwarf_get_GNUIVIS_name"},
{ "DW_GNUIKIND","dwarf_get_GNUIKIND_name"},
{ "DW_UT","dwarf_get_UT_name"},
{ "DW_SECT","dwarf_get_SECT_name"},
{ "DW_DS","dwarf_get_DS_name"},
{ "DW_END","dwarf_get_END_name"},
{ "DW_ATCF","dwarf_get_ATCF_name"},
{ "DW_ACCESS","dwarf_get_ACCESS_name"},
{ "DW_VIS","dwarf_get_VIS_name"},
{ "DW_VIRTUALITY","dwarf_get_VIRTUALITY_name"},
{ "DW_LANG","dwarf_get_LANG_name"},
{ "DW_ID","dwarf_get_ID_name"},
{ "DW_CC","dwarf_get_CC_name"},
{ "DW_INL","dwarf_get_INL_name"},
{ "DW_ORD","dwarf_get_ORD_name"},
{ "DW_DSC","dwarf_get_DSC_name"},
{ "DW_LNCT","dwarf_get_LNCT_name"},
{ "DW_LNS","dwarf_get_LNS_name"},
{ "DW_LNE","dwarf_get_LNE_name"},
{ "DW_ISA","dwarf_get_ISA_name"},
{ "DW_MACRO","dwarf_get_MACRO_name"},
{ "DW_MACINFO","dwarf_get_MACINFO_name"},
{ "DW_CFA","dwarf_get_CFA_name"},
{ "DW_EH","dwarf_get_EH_name"},
{ "DW_FRAME","dwarf_get_FRAME_name"},
{ "DW_CHILDREN","dwarf_get_CHILDREN_name"},
{ "DW_ADDR","dwarf_get_ADDR_name"},
{0,0}
};

static FILE *
open_path(const char *dir, const char *base, const char *direction)
{
    FILE *f = 0;
    /*  POSIX PATH_MAX  would suffice, normally stdio
        BUFSIZ is larger than PATH_MAX */
    static char path_name[BUFSIZ];

    /* 2 == space for / and NUL */
    size_t dirlen = strlen(dir) +1;
    size_t baselen = strlen(base) +1;
    size_t netlen = dirlen + baselen;

    if (netlen >= BUFSIZ) {
        printf("Error opening '%s/%s', name too long\n",dir,base);
        exit(EXIT_FAILURE);
    }
    if (dirlen > 2) {
        safe_strcpy(path_name,BUFSIZ,
            dir,dirlen-1);
        safe_strcpy(path_name+dirlen-1,BUFSIZ -dirlen,
            "/",1);
        safe_strcpy(path_name+dirlen,BUFSIZ -dirlen -1,
            base,baselen-1);
    } else {
        safe_strcpy(path_name,BUFSIZ,base,baselen);
    }
    f = fopen(path_name,direction);
    if (!f) {
        printf("Error opening '%s'\n",path_name);
        exit(EXIT_FAILURE);
    }
    return f;
}


int
main(int argc,char **argv)
{
    int failcount = 0;

    process_args(argc,argv);
    f_dwarf_in = open_path(input_dir,"dwarf.h","r");
    failcount = ParseDefinitionsAndWriteOutput();
    fclose(f_dwarf_in);
    if (failcount) {
        printf("FAIL test_dwnames: count %d\n",failcount);
        return EXIT_FAILURE;
    }
    if (!generate_self_test) {
       printf("build_dwnames_source done \n");
    }
    return 0;
}

/* Print the array used to hold the tags, attributes values */
#ifdef TRACE_ARRAY
static void
PrintArray(void)
{
    int i;
    for (i = 0; i < group_array_count; ++i) {
        printf("[%3d] Name %s_%s, Value %04u\n",
            i,
            group_array[i].ad_prefixname,
            group_array[i].ad_name,
            group_array[i].ad_value);
    }
}
#endif /* TRACE_ARRAY */

/* By including original position we force a stable sort */
static int
Compare(array_data *elem1,array_data *elem2)
{
    if (elem1->ad_value < elem2->ad_value) {
        return -1;
    }
    if (elem1->ad_value > elem2->ad_value) {
        return 1;
    }
    if (elem1->ad_original_position < elem2->ad_original_position) {
        return -1;
    }
    if (elem1->ad_original_position > elem2->ad_original_position) {
        return 1;
    }
    return 0;
}

struct NameEntry {
    char ne_name[MAX_NAME_LEN];
};

/*  We are not particularly concerned about efficiency
    in this test code. */
static const char *
find_function_name(const char *prefix)
{
    int i = 0;

    for ( ; funcpointerarray[i].fp_prefix ; i++) {
        const char *cp = funcpointerarray[i].fp_prefix;
        if (!strcmp(cp,prefix)) {
             const char * f = funcpointerarray[i].fp_name;
             return f;
        }
    }
    return NULL;
}

/*  PRECONDITION: prefix and name must be non-null
    pointers to valid strings.
    Returns DW_DLV_OK or DW_DLV_NO_ENTRY */
static void
write_single_selftest(const char *prefix,
    const char *name_in,
    unsigned int value)
{
    static const char * funcptr = 0;
    static char       lastprefix[20];
    static char       fullname[200];

    int          res = 0; 
    unsigned int prefixlen = 0;
    unsigned int name_in_len = 0;
    const char  *ret_name = 0;

    prefixlen = strlen(prefix);
    name_in_len = strlen(name_in);
    if (prefixlen > (sizeof(lastprefix)-2)) {
        printf("FAIL improper prefix len %u\n",prefixlen);
        exit(EXIT_FAILURE);
    }
    if ((prefixlen + name_in_len +2) >= sizeof(fullname)) {
        printf("FAIL improper prefix/name len %u_%u\n",
            prefixlen,name_in_len);
        exit(EXIT_FAILURE);
    }
    if (!funcptr) {
        /*  First Time */
        funcptr = find_function_name(prefix);
    }
    if (strcmp(prefix,lastprefix)) {
        /* Changing to new prefix */
        safe_strcpy(lastprefix,sizeof(lastprefix),prefix,prefixlen);
        funcptr = find_function_name(prefix);
        if (!funcptr) {
            printf("Error: No function pointer for prefix %s!\n",
                prefix);
            exit(EXIT_FAILURE);
        }
    }
    if (!funcptr) {
        printf("Error: No function pointer for prefix %s!\n",
            prefix);
        exit(EXIT_FAILURE);
    }
    {
        char buf[2000];
        buf[0] = 0;

        printf("    res = %s(%d,&ret_name);\n",funcptr,value);
        sprintf(buf,"check_valid(res,\"%s\", \"%s\", %d, ret_name);\n",
            funcptr,name_in,value);
        printf("    %s\n",buf);
    }
}

/* Write the table and code for a common set of names */
static int
GenerateOneSet(int is_final)
{
    unsigned u;
    unsigned prev_value = 0;
    int failcount = 0;

#ifdef TRACE_ARRAY
    printf("List before sorting:\n");
    PrintArray();
#endif /* TRACE_ARRAY */

    qsort((void *)&group_array,group_array_count,
        sizeof(array_data),(compfn)Compare);

#ifdef TRACE_ARRAY
    printf("\nList after sorting:\n");
    PrintArray();
#endif /* TRACE_ARRAY */

    for (u = 0; u < group_array_count; ++u) {
        /* Check if value already dumped */
        if (u > 0 && group_array[u].ad_value == prev_value) {
            printf("/*  Skipping alternate spelling of value %u */\n",
                u);
            continue;
        }
        prev_value = group_array[u].ad_value;
        if (generate_func_array) {
            char funcname [200];
            const char *pref = group_array[u].ad_prefixname;
            size_t prefixlen =strlen(pref);
            size_t remaining = sizeof(funcname);
            size_t nextc = 0;
            
            funcname[0] = 0;
            safe_strcpy(funcname,remaining,
                "dwarf_get_",10);
            remaining -= 10;
            nextc += 10;
            safe_strcpy(funcname+nextc,remaining,
                pref+3,prefixlen-3);
            remaining -= (prefixlen-3);
            nextc += (prefixlen-3);
            safe_strcpy(funcname+nextc,remaining,
                "_name",5);
            printf("{ \"%s\",\"%s\"},\n",
                group_array[u].ad_prefixname,funcname);
            /* no need to look at others in the group */
            if (is_final) {
                /*  This the end of the group */
                printf("{0,0}\n");
            }
            break;
        }
        if (print_found_content) {
            printf("[%u] (%s) \"%s_",u,
                group_array[u].ad_prefixname,
                group_array[u].ad_prefixname);
            printf("%s\" value: %u (0x%x)\n",
                group_array[u].ad_name,
                group_array[u].ad_value,
                group_array[u].ad_value);
        }
        if (generate_self_test) {
            int res =  0;
            size_t fullnamelen = 0;
            char fullname[200];

            fullname[0] = 0;
            fullnamelen = strlen(group_array[u].ad_prefixname)
                + strlen(group_array[u].ad_name) +2;

            if (fullnamelen >= sizeof(fullname)) {
                 /*  Impossible, really. */
                 printf("Name too long to be real! %lu\n",
                     (unsigned long)fullnamelen);
                 return 1;
            }
            strcpy(fullname,group_array[u].ad_prefixname);
            strcat(fullname,"_");
            strcat(fullname,group_array[u].ad_name);
            write_single_selftest(
                group_array[u].ad_prefixname,
                fullname,
                group_array[u].ad_value);
        }
    }
    reset_group_array();
    group_array_count = 0;
    return failcount;
}

/*  Detect empty lines (and other lines we do not want to read) */
static int
is_skippable_line(char *pLine)
{
    int empty = TRUE;

    for (; *pLine && empty; ++pLine) {
        empty = isspace(*pLine);
    }
    return empty;
}

/*  Parse the 'dwarf.h' file and generate the
    requested information. */
static int
ParseDefinitionsAndWriteOutput(void)
{
    char new_prefix[64];
    char *second_underscore = NULL;
    char type[1000];
    char name[1000];
    char value[1000];
    char extra[1000];
    char line_in[MAX_LINE_SIZE];
    int pending = FALSE;
    int prefix_len = 0;
    int failcount = 0;

    printpartlines(part1);
    /* Process each line from 'dwarf.h' */
    while (!feof(f_dwarf_in)) {
        /*  errno is cleared here so printing errno after
            the fgets is showing errno as set by fgets. */
        char *fgbad = 0;
        errno = 0;
        fgbad = fgets(line_in,sizeof(line_in),f_dwarf_in);
        if (!fgbad) {
            if (feof(f_dwarf_in)) {
                break;
            }
            /*  Is error. errno must be set. */
            printf("Error reading dwarf.h!. Errno %d\n",
                errno);
            return 1;
        }
        if (is_skippable_line(line_in)) {
            continue;
        }
        sscanf(line_in,"%s %s %s %s",type,name,value,extra);
        if (strcmp(type,"#define") ||
            strncmp(name,prefix_root,prefix_root_len)) {
            continue;
        }
        if ( !isdigit(value[0])) {
            /* Skip if not  digits or 0xdigits */
            continue;
        }

        second_underscore = strchr(name + prefix_root_len,'_');
        prefix_len = (int)(second_underscore - name);
        safe_strcpy(new_prefix,sizeof(new_prefix),
            name,prefix_len);

        /* Check for new prefix set */
        if (strcmp(prefix,new_prefix)) {
            if (pending) {
                /* Generate current prefix set */
                failcount += GenerateOneSet(FALSE);
            }
            pending = TRUE;
            safe_strcpy(prefix,sizeof(prefix),
                new_prefix,strlen(new_prefix));
        }

        /* Be sure we have a valid entry */
        if (group_array_count >= GROUP_ARRAY_SIZE) {
            printf("Error: Too many entries for current "
                "group_array size of %d",GROUP_ARRAY_SIZE);
            return 1;
        }
        if (!second_underscore) {
            printf("Line has no underscore %s\n",line_in);
            continue;
        }

        /* Move past the second underscore */
        ++second_underscore;

        {
            char *endptr = 0;
            unsigned long v = strtoul(value,&endptr,0);

            if (endptr == value) {
                /* Not a number */
                continue;
            }
            
            /*  Some values are duplicated, that is ok.
                see GenerateOneSet(). */
            /*  Record current entry */
            if (strlen(second_underscore) >= MAX_NAME_LEN) {
                /* Something is corrupted in dwarf.h. */
                printf("Too long a name %s for max len %d\n",
                    second_underscore,MAX_NAME_LEN);
                exit(EXIT_FAILURE);
            }
            safe_strcpy(group_array[group_array_count].ad_prefixname,
                MAX_NAME_LEN,prefix,strlen(prefix));
            safe_strcpy(group_array[group_array_count].ad_name,
                MAX_NAME_LEN,second_underscore,
                strlen(second_underscore));
            group_array[group_array_count].ad_value = v;
            group_array[group_array_count].ad_original_position =
                group_array_count;
            ++group_array_count;
        }
    }
    if (pending) {
        /* Generate final prefix set */
        failcount += GenerateOneSet(TRUE);
    }
    printpartlines(part3);
    return failcount;
}
