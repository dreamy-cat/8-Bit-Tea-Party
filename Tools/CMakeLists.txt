cmake_minimum_required(VERSION 3.5)

project(Tools LANGUAGES C)

# Compile only with GCC 13.1, x64, C11.
set(CMAKE_C_FLAGS "-std=c11 -Wall -Wextra -O0 -fstack-usage")

add_executable(Tools main.c palettes.c sprites.c)
