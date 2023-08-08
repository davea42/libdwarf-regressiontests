
cmake_minimum_required(VERSION 3.3)
project(cmaketest)
include(FetchContent)
#set_source_group(MYSOURCES "Source Files" test.c)
add_executable(myprogram test.c)
FetchContent_Declare(
  libdwarf
  GIT_REPOSITORY https://github.com/davea42/libdwarf-code.git
  #  Aug 7 2023 version
  GIT_TAG 340b0e131922943f00dacd4ee4d3389fbcbd2e76
)
FetchContent_MakeAvailable(libdwarf)

# dwarf-static is the target created by the
# base CMakeLists.txt in the libdwarf-code project.
# If adding cmake choices here causes the build to be
# a shared object libdwarf.so/dll the correct
# reference here would be dwarf-shared
target_link_libraries(myprogram PRIVATE dwarf-static)
