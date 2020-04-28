
#include <sys/stat.h>

#ifdef _WIN32
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# undef WIN32_LEAN_AND_MEAN
# include <io.h> /* _get_osfhandle() */
# include <errno.h>
#else
# include <fcntl.h> /* open() */
# include <unistd.h> /* close() */
# include <sys/mman.h> /* mmap() */
#endif

#include "pe_map.h"


#ifdef _WIN32

/**
 * @param map Reference to a map. Always valid.
 *
 * Set @p map from the handle @p h.
 *
 * @see pe_map_set_from_file()
 * @see pe_map_set_from_fd()
 *
 * @internal
 */
static int
pe_map_set_from_handle(Pe_Map *map)
{
    HANDLE fm;
    LARGE_INTEGER size;

    if (!GetFileSizeEx(map->file, &size))
        return 0;

    map->size = size.QuadPart;
    fm = CreateFileMapping(map->file,
                            NULL, PAGE_READONLY,
                            0, 0, NULL);
    if (!fm)
        return 0;

    /* map file in READ only mode */
    map->base = MapViewOfFile(fm, FILE_MAP_READ, 0, 0, 0);
    CloseHandle(fm);

    return (map->base != NULL);
}

/**
 * @param map Reference to a map. Always valid.
 * @param filename Name of the file;
 *
 * Set @p map from the file which name is @p filename.
 *
 * @see pe_map_set_from_handle()
 * @see pe_map_set_from_fd()
 */
int
pe_map_set_from_file(Pe_Map *map, LPCTSTR filename)
{
    if (!filename || !*filename)
        return 0;

    map->file = CreateFile(filename,
                           GENERIC_READ | FILE_READ_ATTRIBUTES,
                           0,
                           NULL,
                           OPEN_EXISTING,
                           FILE_ATTRIBUTE_NORMAL,
                           NULL);
    if (map->file == INVALID_HANDLE_VALUE)
        return 0;

    map->from_fd = 0;

    return pe_map_set_from_handle(map);
}

/**
 * @param map Reference to a map. Always valid.
 * @param filename Name of the file;
 *
 * Set @p map from the file which name is @p filename.
 *
 * @see pe_map_set_from_handle()
 * @see pe_map_set_from_file()
 */
int
pe_map_set_from_fd(Pe_Map *map, int fd)
{
    struct stat buf;

    if (fd < 0)
        return 0;

    if ((fstat(fd, &buf) < 0) ||
        !((buf.st_mode & _S_IFMT) == _S_IFREG))
        return 0;

    map->file = (HANDLE)_get_osfhandle(fd);
    if ((map->file == INVALID_HANDLE_VALUE) &&
        (errno == EBADF))
        return 0;

    map->from_fd = 1;

    return pe_map_set_from_handle(map);
}

void
pe_map_unset(Pe_Map *map)
{
    UnmapViewOfFile(map->base);
    if (!map->from_fd)
        CloseHandle(map->file);
}

#else

/**
 * @param map Reference to a map. Always valid.
 * @param filename Name of the file;
 *
 * Set @p map from the file which name is @p filename.
 *
 * @see pe_map_set_from_handle()
 * @see pe_map_set_from_file()
 */
int
pe_map_set_from_fd(Pe_Map *map, int fd)
{
    struct stat buf;

    if (fd < 0)
        return 0;

    if ((fstat(fd, &buf) < 0) ||
        !((buf.st_mode & S_IFMT) == S_IFREG))
        return 0;

    map->fd = fd;
    map->size = (long long)buf.st_size;
    map->base = mmap(NULL, map->size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (map->base == MAP_FAILED)
        return 0;

    map->from_fd = 1;

    return 1;
}

/**
 * @param map Reference to a map. Always valid.
 * @param filename Name of the file;
 *
 * Set @p map from the file which name is @p filename.
 *
 * @see pe_map_set_from_handle()
 * @see pe_map_set_from_fd()
 */
int
pe_map_set_from_file(Pe_Map *map, const char *filename)
{
    int fd;
    int ret;

    if (!filename || !*filename)
        return 0;

    fd = open(filename, O_RDONLY);
    if (fd < 0)
        return 0;

    ret = pe_map_set_from_fd(map, fd);

    map->from_fd = 0;

    return ret;
}

void
pe_map_unset(Pe_Map *map)
{
    munmap(map->base, map->size);
    if (!map->from_fd)
        close(map->fd);
}

#endif
