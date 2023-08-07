
project(cmaketest)
cmake_minimum_required(VERSION 3.3)
include(FetchContent)
FetchContent_Declare(
  libdwarf
  GIT_REPOSITORY https://github.com/davea42/libdwarf-code.git
  GIT_TAG 61fb3beeb9f871794719208743218bac8d34b870
)
FetchContent_MakeAvailable(libdwarf)
