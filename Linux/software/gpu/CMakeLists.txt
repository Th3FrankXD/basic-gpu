cmake_minimum_required(VERSION 3.7)

project(gpu-test LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_BUILD_TYPE "Release")

# Include headers
include_directories(headers)
# Add source code
file(GLOB_RECURSE SOURCES src/*.cpp)
add_executable(gpu-test ${SOURCES})