


/*
    Notes on the content 
    of a .note.gnu.build-id section.

    The format is as follows.

    char [4] namesize (size of the owner name)
    char [4] descrsize (the length of the build-id data)
    char [4] type The type.  For build id it is
              3: NT_GNU_BUILD_ID
    Followed by the namesize bytes (for now GNU with
         a trailing NUL to end the string and the namesize
         covers the NUL as well as the non-NUL name bytes)

    Followed by the descrsize bytes (20) of the build-id.
    char[20] build-id bytes

*/


