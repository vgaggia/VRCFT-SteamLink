cmake_minimum_required(VERSION 3.15)
project(VRCFT-SteamLink VERSION 1.0.0)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build options
option(BUILD_NATIVE_ONLY "Build only the native C++ library" OFF)

# Add the native C++ library
add_subdirectory(SLVRCFT/SLOSCParser)

# Instructions for building the C# module
message(STATUS "")
message(STATUS "==============================================")
message(STATUS "  VRCFT-SteamLink Build Configuration")
message(STATUS "==============================================")
message(STATUS "Native library (SLOSCParser) will be built with CMake")
message(STATUS "")
message(STATUS "To build the complete module:")
message(STATUS "  Linux:   ./build-linux.sh [Release|Debug]")
message(STATUS "  Windows: .\\build-windows.ps1 [-BuildType Release|Debug]")
message(STATUS "")
message(STATUS "Or build manually:")
message(STATUS "  1. Build native library: cmake --build . --config Release")
message(
  STATUS "  2. Copy output to: SLVRCFT/SLExtTrackingModule/bin/Release/net7.0")
message(
  STATUS
    "  3. Build C# module: dotnet build SLVRCFT/SLExtTrackingModule/SLExtTrackingModule.csproj"
)
message(STATUS "==============================================")
message(STATUS "")
