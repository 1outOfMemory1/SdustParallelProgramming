# CMAKE generated file: DO NOT EDIT!
# Generated by "NMake Makefiles" Generator, CMake Version 3.17

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE
NULL=nul
!ENDIF
SHELL = cmd.exe

# The CMake executable.
CMAKE_COMMAND = "D:\EnglishSoftware\clion\CLion 2020.2\bin\cmake\win\bin\cmake.exe"

# The command to remove a file.
RM = "D:\EnglishSoftware\clion\CLion 2020.2\bin\cmake\win\bin\cmake.exe" -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug

# Include any dependencies generated for this target.
include CMakeFiles\image.dir\depend.make

# Include the progress variables for this target.
include CMakeFiles\image.dir\progress.make

# Include the compile flags for this target's objects.
include CMakeFiles\image.dir\flags.make

CMakeFiles\image.dir\image_generated_image.cu.obj: CMakeFiles\image.dir\image_generated_image.cu.obj.depend
CMakeFiles\image.dir\image_generated_image.cu.obj: CMakeFiles\image.dir\image_generated_image.cu.obj.Debug.cmake
CMakeFiles\image.dir\image_generated_image.cu.obj: ..\image.cu
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug\CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building NVCC (Device) object CMakeFiles/image.dir/image_generated_image.cu.obj"
	cd F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug\CMakeFiles\image.dir
	echo >nul && "D:\EnglishSoftware\clion\CLion 2020.2\bin\cmake\win\bin\cmake.exe" -E make_directory F:/project/github/unfinished/SdustParallelProgramming/independentHomeworkMatrixMultiply/parallel/cmake-build-debug/CMakeFiles/image.dir//.
	echo >nul && "D:\EnglishSoftware\clion\CLion 2020.2\bin\cmake\win\bin\cmake.exe" -D verbose:BOOL=$(VERBOSE) -D build_configuration:STRING=Debug -D generated_file:STRING=F:/project/github/unfinished/SdustParallelProgramming/independentHomeworkMatrixMultiply/parallel/cmake-build-debug/CMakeFiles/image.dir//./image_generated_image.cu.obj -D generated_cubin_file:STRING=F:/project/github/unfinished/SdustParallelProgramming/independentHomeworkMatrixMultiply/parallel/cmake-build-debug/CMakeFiles/image.dir//./image_generated_image.cu.obj.cubin.txt -P F:/project/github/unfinished/SdustParallelProgramming/independentHomeworkMatrixMultiply/parallel/cmake-build-debug/CMakeFiles/image.dir//image_generated_image.cu.obj.Debug.cmake
	cd F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug

# Object files for target image
image_OBJECTS =

# External object files for target image
image_EXTERNAL_OBJECTS = \
"F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug\CMakeFiles\image.dir\image_generated_image.cu.obj"

image.exe: CMakeFiles\image.dir\image_generated_image.cu.obj
image.exe: CMakeFiles\image.dir\build.make
image.exe: "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.0\lib\x64\cudart_static.lib"
image.exe: CMakeFiles\image.dir\objects1.rsp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug\CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable image.exe"
	"D:\EnglishSoftware\clion\CLion 2020.2\bin\cmake\win\bin\cmake.exe" -E vs_link_exe --intdir=CMakeFiles\image.dir --rc="D:\Windows Kits\10\bin\10.0.18362.0\x64\rc.exe" --mt="D:\Windows Kits\10\bin\10.0.18362.0\x64\mt.exe" --manifests  -- D:\EnglishSoftware\visualStudio2019\VC\Tools\MSVC\14.27.29110\bin\Hostx64\x64\link.exe /nologo @CMakeFiles\image.dir\objects1.rsp @<<
 /out:image.exe /implib:image.lib /pdb:F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug\image.pdb /version:0.0  /machine:x64 /debug /INCREMENTAL /subsystem:console  "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.0\lib\x64\cudart_static.lib" kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib 
<<

# Rule to build all files generated by this target.
CMakeFiles\image.dir\build: image.exe

.PHONY : CMakeFiles\image.dir\build

CMakeFiles\image.dir\clean:
	$(CMAKE_COMMAND) -P CMakeFiles\image.dir\cmake_clean.cmake
.PHONY : CMakeFiles\image.dir\clean

CMakeFiles\image.dir\depend: CMakeFiles\image.dir\image_generated_image.cu.obj
	$(CMAKE_COMMAND) -E cmake_depends "NMake Makefiles" F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug F:\project\github\unfinished\SdustParallelProgramming\independentHomeworkMatrixMultiply\parallel\cmake-build-debug\CMakeFiles\image.dir\DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles\image.dir\depend
