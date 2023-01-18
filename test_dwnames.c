/*
    Copyright 2023 David Anderson. All rights reserved.


*/
/*   Used by regession tests: DWARFTESTS.sh
*/


#ifdef _WIN32
#define _CRT_SECURE_NO_WARNINGS
#endif /* _WIN32 */

#include <stddef.h> /* NULL size_t */
#include <ctype.h>  /* isspace() */
#include <errno.h>  /* errno */
#include <stdio.h>  /* fgets() fprintf() printf() sscanf() */
#include <stdlib.h> /* exit() qsort() strtoul() */
#include <string.h> /* strchr() strcmp() strcpy() strlen() strncmp() */

#include "dwarf_safe_strcpy.h"
#include "dd_minimal.h"


/*  test_dwnames.c
    Reads libdwarf.h and for each DW_AT_* (for all such
    defines calls the dwarf_get_AT_name or equivalent
    and verifies the result string matches expectations.
    (such as the TAG name string for a particular tag).

*/

static void GenerateOneSet(void);
static void WriteNameDeclarations(void);
#ifdef TRACE_ARRAY
static void PrintArray(void);
#endif /* TRACE_ARRAY */
static int is_skippable_line(char *pLine);
static void ParseDefinitionsAndWriteOutput(void);

/* We don't need really long lines: the input file is simple. */
#define MAX_LINE_SIZE 1000
/*  We don't need a variable array size,
    it just has to be big enough. */
#define ARRAY_SIZE 350

#define MAX_NAME_LEN 64

/* To store entries from dwarf.h */
typedef struct {
    char     name[MAX_NAME_LEN];  /* short name */
    unsigned value; /* value */
    /* Original spot in array.   Lets us guarantee a stable sort. */
    unsigned original_position;
} array_data;

/*  A group_array is a grouping from dwarf.h.
    All the TAGs are one group, all the
    FORMs are another group, and so on. */
static array_data group_array[ARRAY_SIZE];
static unsigned array_count = 0;

typedef int (*compfn)(const void *,const void *);
static int Compare(array_data *,array_data *);

static const char *prefix_root = "DW_";
static const unsigned prefix_root_len = 3;

/* f_dwarf_in is the input dwarf.h. The others are output files. */
static FILE *f_dwarf_in;
static FILE *f_results_out;

/* Size unchecked, but large enough. */
static char prefix[200] = "";

static const char *usage[] = {
    "Usage: gennames <options>",
    "    -i  <path/src/lib/libdwarf",
    "    -o output-table-path",
    "",
};

static void
print_args(int argc, char *argv[])
{
    int index;
    printf("Arguments: ");
    for (index = 1; index < argc; ++index) {
        printf("%s ",argv[index]);
    }
    printf("\n");
}

static char *input_dir = 0;
static char *output_file = 0;

static void
print_version(const char * name)
{
#ifdef _DEBUG
    const char *acType = "Debug";
#else
    const char *acType = "Release";
#endif /* _DEBUG */

    printf("%s [%s %s]\n",name,PACKAGE_VERSION,acType);
}

static void
print_usage_message(const char *options[])
{
    int index;
    for (index = 0; *options[index]; ++index) {
        printf("%s\n",options[index]);
    }
}

/* process arguments */
static void
process_args(int argc, char *argv[])
{
    int c = 0;
    int usage_error = FALSE;

    for(i = 1; i < argc;++i) {
        if (!strcmp(argv[i],"-i") {
            ++i;
            input_dir = argv[i];
            continue
        }
        if (!strcmp(argv[i],"-o") {
            ++i;
            output_file = argv[i];
            continue
        default:
            usage_error = TRUE;
            print_usage_message(usage);
            exit(EXIT_FAILURE);
        }
    }

    if (i != argc) {
        print_usage_message(usage);
        exit(EXIT_FAILURE);
    }
}

int
main(int argc,char **argv)
{
    process_args(argc,argv);
    f_dwarf_in = open_path(input_dir,"dwarf.h,"r");
    f_results_out = open_path("",output_file,"w");
    ParseDefinitionsAndWriteOutput();
    WriteNameDeclarations();
    fclose(f_dwarf_in);
    fclose(f_results_out);
    return 0;
}

/* Print the array used to hold the tags, attributes values */
#ifdef TRACE_ARRAY
static void
PrintArray(void)
{
    int i;
    for (i = 0; i < array_count; ++i) {
        printf("%d: Name %s_%s, Value 0x%04x\n",
            i,prefix,
            array[i].name,
            array[i].value);
    }
}
#endif /* TRACE_ARRAY */

/* By including original position we force a stable sort */
static int
Compare(array_data *elem1,array_data *elem2)
{
    if (elem1->value < elem2->value) {
        return -1;
    }
    if (elem1->value > elem2->value) {
        return 1;
    }
    if (elem1->original_position < elem2->original_position) {
        return -1;
    }
    if (elem1->original_position > elem2->original_position) {
        return 1;
    }
    return 0;
}

static FILE *
open_path(const char *base, const char *file, const char *direction)
{
    FILE *f = 0;
    /*  POSIX PATH_MAX  would suffice, normally stdio
        BUFSIZ is larger than PATH_MAX */
    static char path_name[BUFSIZ];

    /* 2 == space for / and NUL */
    size_t baselen = strlen(base) +1;
    size_t filelen = strlen(file) +1;
    size_t netlen = baselen + filelen;

    if (netlen >= BUFSIZ) {
        printf("Error opening '%s/%s', name too long\n",base,file);
        exit(EXIT_FAILURE);
    }
    if (!strlen(base)) {
        _dwarf_safe_strcpy(path_name,BUFSIZ,
            base,baselen-1);
        _dwarf_safe_strcpy(path_name+baselen-1,BUFSIZ -baselen,
        "/",1);
        _dwarf_safe_strcpy(path_name+baselen,BUFSIZ -baselen -1,
            file,filelen-1);
    } else {
        _dwarf_safe_strcpy(path_name,BUFSIZ,file,filelen);
    }
    f = fopen(path_name,direction);
    if (!f) {
        printf("Error opening '%s'\n",path_name);
        exit(EXIT_FAILURE);
    }
    return f;
}


    f_dwarf_in = open_path(input_name,dwarf_h,"r");
    f_dwarf_in = open_path(input_name,dwarf_h,"r");


/* Close files and write basic trailers */
static void
WriteFileTrailers(void)
{
    /* Generate entries for 'dwarf_names.c' */
    fprintf(f_names_c,"\n/* END FILE */\n");
}

struct NameEntry {
    char ne_name[MAX_NAME_LEN];
};

/*  Sort these by name, then write */
#define MAX_NAMES 200
static struct NameEntry nameentries[MAX_NAMES];
static int  curnameentry;

/*  We compare as capitals for sorting purposes.
    This does not do right by UTF8, but the strings
    are from in dwarf.h and are plain ASCII.  */
static int
CompareName(struct NameEntry *elem1,struct NameEntry *elem2)
{
    char *cpl = elem1->ne_name;
    char *cpr = elem2->ne_name;
    for ( ; *cpl && *cpr; ++cpl,++cpr) {
        unsigned char l = *cpl;
        unsigned char r = *cpr;
        unsigned char l1 = 0;
        unsigned char r1 = 0;

        if (l == r) {
            continue;
        }
        if (l <= 'z' && l >= 'a') {
            l1 = l - 'a' + 'A';
            l = l1;
        }
        if (r <= 'z' && r >= 'a') {
            r1 = r -'a'+ 'A';
            r = r1;
        }
        if (l < r) {
            return -1;
        }
        if (l > r) {
            return 1;
        }
        continue;
    }
    if (*cpl < *cpr) {
        return -1;
    }
    if (*cpl > *cpr) {
        return 1;
    }
    return 0; /* should NEVER happen */
}

/*  Sort into name order for readability of the declarations,
    then print the declarations. */
static void
WriteNameDeclarations(void)
{
    int i = 0;

    qsort((void *)&nameentries,curnameentry,
        sizeof(struct NameEntry),(compfn)CompareName);
    /* Generate entries for 'dwarf_names.h' and libdwarf.h */
    for ( ; i < curnameentry;++i) {
        fprintf(f_names_h,"DW_API int dwarf_get_%s_name"
            "(unsigned int /*val_in*/,\n",nameentries[i].ne_name);
        fprintf(f_names_h,"    const char ** /*s_out */);\n");
    }
}
static void
SaveNameDeclaration(char *prefix_id)
{
    unsigned long length = 0;

    if (curnameentry >= MAX_NAMES) {
        printf("FAIL gennames. Exceeded limit of declarations %d "
            "when given %s\n",curnameentry,prefix_id);
        exit(EXIT_FAILURE);
    }
    length = strlen(prefix_id);
    if (length >= MAX_NAME_LEN) {
        printf("FAIL gennames. Exceeded limit of declaration "
            "name length at %ul "
            "when given %s\n",curnameentry,prefix_id);
        exit(EXIT_FAILURE);
    }
    strcpy(nameentries[curnameentry].ne_name,prefix_id);
    ++curnameentry;
}

/* Write the table and code for a common set of names */
static void
GenerateOneSet(void)
{
    unsigned u;
    unsigned prev_value = 0;
    char *prefix_id = prefix + prefix_root_len;
    unsigned actual_array_count = 0;

#ifdef TRACE_ARRAY
    printf("List before sorting:\n");
    PrintArray();
#endif /* TRACE_ARRAY */

    /*  Sort the array, because the values in 'libdwarf.h' are not in
        ascending order; if we use '-t' we must be sure the values are
        sorted, for the binary search to work properly.
        We want a stable sort, hence mergesort.  */
    qsort((void *)&group_array,array_count,
        sizeof(array_data),(compfn)Compare);

#ifdef TRACE_ARRAY
    printf("\nList after sorting:\n");
    PrintArray();
#endif /* TRACE_ARRAY */

    SaveNameDeclaration(prefix_id);
    /* Generate code for 'dwarf_names.c' */
    fprintf(f_names_c,"/* ARGSUSED */\n");
    fprintf(f_names_c,"int\n");
    fprintf(f_names_c,"dwarf_get_%s_name (unsigned int val,\n",
        prefix_id);
    fprintf(f_names_c,"    const char ** s_out)\n");
    fprintf(f_names_c,"{\n");
    fprintf(f_names_c,"    switch (val) {\n");

    for (u = 0; u < array_count; ++u) {
        /* Check if value already dumped */
        if (u > 0 && group_array[u].value == prev_value) {
            fprintf(f_names_c,
                "    /*  Skipping alternate spelling of value\n");
            fprintf(f_names_c,
                "        0x%x. %s_%s */\n",
                (unsigned)prev_value,
                prefix,
                group_array[u].name);
            continue;
        }
        prev_value = group_array[u].value;

        /* Generate entries for 'dwarf_names.c' */
        fprintf(f_names_c,"    case %s_%s:\n",
            prefix,group_array[u].name);
        fprintf(f_names_c,"        *s_out = \"%s_%s\";\n",
            prefix,group_array[u].name);
        fprintf(f_names_c,"        return DW_DLV_OK;\n");
        ++actual_array_count;
    }

    /* Closing entries for 'dwarf_names.h' */
    fprintf(f_names_c,"    default: break;\n");
    fprintf(f_names_c,"    }\n");
    fprintf(f_names_c,"    return DW_DLV_NO_ENTRY;\n");
    fprintf(f_names_c,"}\n");
    /* Mark the group_array as empty */
    array_count = 0;
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

/* Parse the 'dwarf.h' file and generate the tables */
static void
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
            fprintf(stderr,"Error reading dwarf.h!. Errno %d\n",
                errno);
            exit(EXIT_FAILURE);
        }
        if (is_skippable_line(line_in)) {
            continue;
        }
        sscanf(line_in,"%s %s %s %s",type,name,value,extra);
        if (strcmp(type,"#define") ||
            strncmp(name,prefix_root,prefix_root_len)) {
            continue;
        }

        second_underscore = strchr(name + prefix_root_len,'_');
        prefix_len = (int)(second_underscore - name);
        _dwarf_safe_strcpy(new_prefix,sizeof(new_prefix),
            name,prefix_len);

        /* Check for new prefix set */
        if (strcmp(prefix,new_prefix)) {
            if (pending) {
                /* Generate current prefix set */
                GenerateOneSet();
            }
            pending = TRUE;
            _dwarf_safe_strcpy(prefix,sizeof(prefix),
                new_prefix,strlen(new_prefix));
        }

        /* Be sure we have a valid entry */
        if (array_count >= ARRAY_SIZE) {
            printf("Too many entries for current "
                "group_array size of %d",ARRAY_SIZE);
            exit(EXIT_FAILURE);
        }
        if (!second_underscore) {
            printf("Line has no underscore %s\n",line_in);
            continue;
        }

        /* Move past the second underscore */
        ++second_underscore;

        {
            unsigned long v = strtoul(value,NULL,16);
            /*  Some values are duplicated, that is ok.
                After the sort we will weed out the duplicate values,
                see GenerateOneSet(). */
            /*  Record current entry */
            if (strlen(second_underscore) >= MAX_NAME_LEN) {
                printf("Too long a name %s for max len %d\n",
                    second_underscore,MAX_NAME_LEN);
                exit(EXIT_FAILURE);
            }
            _dwarf_safe_strcpy(group_array[array_count].name,
                MAX_NAME_LEN,second_underscore,
                strlen(second_underscore));
            group_array[array_count].value = v;
            group_array[array_count].original_position = array_count;
            ++array_count;
        }
    }
    if (pending) {
        /* Generate final prefix set */
        GenerateOneSet();
    }
}
