cmake_minimum_required(VERSION 3.17)
project(aa)

set(CMAKE_CXX_STANDARD 14)

add_executable(hello hello.cpp)
add_executable(noparafor noparafor.cpp)
add_executable(parafor1 parafor1.cpp)
add_executable(parafor2 parafor2.cpp)
add_executable(private private.cpp)