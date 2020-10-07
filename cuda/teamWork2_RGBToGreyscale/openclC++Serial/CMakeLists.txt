cmake_minimum_required(VERSION 3.8.1)
project(assigment)

# Where to find CMake modules and OpenCV
#set(OpenCV_DIR "D:\\EnglishSoftware\\c++Environment\\mingwOpencv\\install")
set(OpenCV_DIR "D:\\EnglishSoftware\\c++Environment\\opencv440\\build")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

find_package(OpenCV REQUIRED)

add_executable(RGB2Grey RGB2Grey.cpp)

# add libs you need
set(OpenCV_LIBS opencv_core opencv_imgproc opencv_highgui opencv_imgcodecs)

# linking
target_link_libraries(RGB2Grey ${OpenCV_LIBS})