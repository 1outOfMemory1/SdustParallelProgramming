##cmake_minimum_required(VERSION 3.8)
##project(opencv)
##
##option(ENABLE_CUDA "" ON)
##find_package(CUDA REQUIRED)
##if(CUDA_FOUND)
##    include_directories(${CUDA_INCLUDE_DIRS})
##endif()
##
##find_package(OpenCV REQUIRED)
##
##set(CMAKE_CXX_STANDARD 11)
##
##add_executable(opencv opencv.cpp)
##CUDA_ADD_EXECUTABLE(main main.cu)
##
##target_link_libraries(opencv ${OpenCV_LIBS})
##target_link_libraries(main ${OpenCV_LIBS})
##
##
##
##
### cmake needs this line
##cmake_minimum_required(VERSION 3.1)
##
##if(NOT DEFINED EXAMPLE_NAME)
##    message(FATAL_ERROR "Invalid build script: missing EXAMPLE_NAME")
##endif()
##if(NOT DEFINED EXAMPLE_FILE)
##    message(FATAL_ERROR "Invalid build script: missing EXAMPLE_FILE")
##endif()
##
##file(TO_CMAKE_PATH "${EXAMPLE_FILE}" EXAMPLE_FILE)
##message(STATUS "Project: ${EXAMPLE_NAME}")
##message(STATUS "File   : ${EXAMPLE_FILE}")
##
### Define project name
##project(${EXAMPLE_NAME})
##
### Find OpenCV, you may need to set OpenCV_DIR variable
### to the absolute path to the directory containing OpenCVConfig.cmake file
### via the command line or GUI
##find_package(OpenCV REQUIRED)
##
### If the package has been found, several variables will
### be set, you can find the full list with descriptions
### in the OpenCVConfig.cmake file.
### Print some message showing some of them
##message(STATUS "OpenCV library status:")
##message(STATUS "    config: ${OpenCV_DIR}")
##message(STATUS "    version: ${OpenCV_VERSION}")
##message(STATUS "    libraries: ${OpenCV_LIBS}")
##message(STATUS "    include path: ${OpenCV_INCLUDE_DIRS}")
##
### Declare the executable target built from your sources
##add_executable(${EXAMPLE_NAME} "${EXAMPLE_FILE}")
##
### Link your application with OpenCV libraries
##target_link_libraries(${EXAMPLE_NAME} PRIVATE ${OpenCV_LIBS})
#
#
#
## cmake needs this line
#cmake_minimum_required(VERSION 3.5)
#
## Define project name
#project(test)
## Find OpenCV, you may need to set OpenCV_DIR variable
## to the absolute path to the directory containing OpenCVConfig.cmake file
## via the command line or GUI
#find_package(OpenCV 4.5.0 REQUIRED)
#
#SET(CMAKE_CXX_STANDARD 11)
#
#option(ENABLE_CUDA "" ON)
#find_package(CUDA REQUIRED)
#if(CUDA_FOUND)
#    include_directories(${CUDA_INCLUDE_DIRS})
#endif()
#
## If the package has been found, several variables will
## be set, you can find the full list with descriptions
## in the OpenCVConfig.cmake file.
## Print some message showing some of them
#message(STATUS "OpenCV library status:")
#message(STATUS "    version: ${OpenCV_VERSION}")
#message(STATUS "    libraries: ${OpenCV_LIBS}")
#message(STATUS "    include path: ${OpenCV_INCLUDE_DIRS}")
#link_directories("/home/fei/anaconda3/lib")
#if(CMAKE_VERSION VERSION_LESS "3.5.1")
#    # Add OpenCV headers location to your include paths
#    include_directories(${OpenCV_INCLUDE_DIRS})
#endif()
#
#set(CMAKE_CXX_FLAGS_DEBUG " $ENV{CXXFLAGS} -std=c++11 -DDEBUG -DUSE_CUDA -DDLIB_NO_GUI_SUPPORT -g -O0 -w")
#set(CMAKE_CXX_FLAGS_RELEASE " $ENV{CXXFLAGS} -std=c++11 -DNDEBUG -DUSE_CUDA -DDLIB_NO_GUI_SUPPORT -O3 -w")
#set(CUDA_NVCC_FLAGS ${CMAKE_CXX_FLAGS_RELEASE} ${CUDA_NVCC_FLAGS} -gencode arch=compute_61,code=sm_61; --use_fast_math)
#
## Declare the executable target built from your sources
## add_executable(test TTT.cpp main2.cu)
## CUDA_ADD_LIBRARY(test SHARED main2.cu TTT.cpp)
#CUDA_ADD_EXECUTABLE(test main.cu)
#
#
#add_executable(opencv opencv.cpp)
#target_link_libraries(opencv ${OpenCV_LIBS})
#
## Link your application with OpenCV libraries
#target_link_libraries(test ${OpenCV_LIBS})


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



set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")

find_package(OpenCV REQUIRED)


# add libs you need
set(OpenCV_LIBS opencv_core opencv_imgproc opencv_highgui opencv_imgcodecs)

# Declare the executable target built from your sources
# add_executable(test TTT.cpp main2.cu)
# CUDA_ADD_LIBRARY(test SHARED main2.cu TTT.cpp)
CUDA_ADD_EXECUTABLE(test main.cu)

# Link your application with OpenCV libraries

target_link_libraries(test ${OpenCV_LIBS})
