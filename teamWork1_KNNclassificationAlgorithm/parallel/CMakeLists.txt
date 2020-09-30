cmake_minimum_required(VERSION 3.14)
project(Hello)
<<<<<<< HEAD
#set(CUDA_NVCC_FLAGS -O3; -G; -g;-std=c++11;)
=======
set(CUDA_NVCC_FLAGS -O3; -G; -g;-std=c++11;)
>>>>>>> b7bde6c91907a2b0992f15508513c50619850556
set(CMAKE_CXX_STANDARD 14)
find_package(CUDA REQUIRED)
file(GLOB CU main.cu)
cuda_add_executable(main main.cu yhncsv.cpp yhncsv.h common.h)
