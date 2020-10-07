# cmake needs this line
cmake_minimum_required(VERSION 3.5)

# Define project name
project(test)
# Find OpenCV, you may need to set OpenCV_DIR variable
# to the absolute path to the directory containing OpenCVConfig.cmake file
# via the command line or GUI
set(OpenCV_DIR "D:\\EnglishSoftware\\c++Environment\\opencv440\\build")
find_package(OpenCV REQUIRED)

option(ENABLE_CUDA "" ON)
find_package(CUDA REQUIRED)
if(CUDA_FOUND)
    include_directories(${CUDA_INCLUDE_DIRS})
endif()

# If the package has been found, several variables will
# be set, you can find the full list with descriptions
# in the OpenCVConfig.cmake file.
# Print some message showing some of them
message(STATUS "OpenCV library status:")
message(STATUS "    version: ${OpenCV_VERSION}")
message(STATUS "    libraries: ${OpenCV_LIBS}")
message(STATUS "    include path: ${OpenCV_INCLUDE_DIRS}")
link_directories("/home/fei/anaconda3/lib")


set(OpenCV_DIR "D:\\EnglishSoftware\\c++Environment\\opencv440\\build")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

find_package(OpenCV REQUIRED)


# add libs you need
set(OpenCV_LIBS opencv_core opencv_imgproc opencv_highgui opencv_imgcodecs)

# Declare the executable target built from your sources
# add_executable(test TTT.cpp main2.cu)
# CUDA_ADD_LIBRARY(test SHARED main2.cu TTT.cpp)
CUDA_ADD_EXECUTABLE(main main.cu)

# Link your application with OpenCV libraries

target_link_libraries(main ${OpenCV_LIBS})

