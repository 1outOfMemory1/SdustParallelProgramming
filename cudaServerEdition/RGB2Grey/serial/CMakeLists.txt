cmake_minimum_required(VERSION 3.7)
project(assigment)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

# Where to find CMake modules and OpenCV
#set(OpenCV_DIR "D:\\EnglishSoftware\\c++Environment\\mingwOpencv\\install")
set(OpenCV_DIR "D:\\EnglishSoftware\\c++Environment\\mingwOpencv3411\\install")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

find_package(OpenCV REQUIRED)

add_executable(RGB2Grey RGB2Grey.cpp)

# add libs you need
set(OpenCV_LIBS opencv_core opencv_imgproc opencv_highgui opencv_imgcodecs)

# linking
target_link_libraries(RGB2Grey ${OpenCV_LIBS})