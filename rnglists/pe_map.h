#ifndef PE_MAP_H
#define PE_MAP_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Pe_Map Pe_Map;

struct Pe_Map
{
    unsigned char *base;
    long long size;
#ifdef _WIN32
    HANDLE file;
#else
    int fd;
#endif
    unsigned int from_fd : 1;
};

#ifdef _WIN32
int pe_map_set_from_file(Pe_Map *map, LPCTSTR filename);
#else
int pe_map_set_from_file(Pe_Map *map, const char *filename);
#endif

int pe_map_set_from_fd(Pe_Map *map, int fd);

void pe_map_unset(Pe_Map *map);

#ifdef __cplusplus
}
#endif

#endif /* PE_MAP_H */
