cmake_minimum_required(VERSION 3.14)
project(learnOpenmp)
set(CMAKE_CXX_STANDARD 11)

FIND_PACKAGE(OpenMP REQUIRED)
if(OPENMP_FOUND)
    message("OPENMP FOUND")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

SET(CMAKE_CXX_COMPILER mpicxx)
SET(CMAKE_C_COMPILER  mpicc)
add_executable(openmpMatrixMultiply openmpMatrixMultiply.cpp)
add_executable(mpiMatrixMultiply mpiMatrixMultiply.cpp)
add_executable(hybridOpenmpAndMpiMatrixMultiply hybridOpenmpAndMpiMatrixMultiply.cpp)
add_executable(mpiMatrixMultiplyExample mpiMatrixMultiplyExample.cpp)
add_executable(mpiMatrixMultiplyAbc mpiMatrixMultiplyAbc.cpp)
add_executable(test test.cpp)

