cmake_minimum_required(VERSION 3.14)
project(Hello)

set(CMAKE_CXX_STANDARD 14)
find_package(CUDA REQUIRED)
file(GLOB CU main.cu)
cuda_add_executable(main main.cu)