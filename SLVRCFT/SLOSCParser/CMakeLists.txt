cmake_minimum_required(VERSION 3.15)
project(
  SLOSCParser
  VERSION 1.0.0
  LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files
set(SOURCES sloscparser.cpp)

set(HEADERS sloscparser.h miniosc.h)

# Create shared library
add_library(SLOSCParser SHARED ${SOURCES} ${HEADERS})

# Platform-specific configurations
if(WIN32)
  # Windows-specific settings
  target_compile_definitions(
    SLOSCParser PRIVATE _CRT_SECURE_NO_WARNINGS _WINSOCK_DEPRECATED_NO_WARNINGS)
  target_link_libraries(SLOSCParser PRIVATE ws2_32)
elseif(UNIX)
  # Linux-specific settings
  target_compile_definitions(SLOSCParser PRIVATE _POSIX_C_SOURCE=200809L)
  # Set symbol visibility for exports
  set_target_properties(SLOSCParser PROPERTIES CXX_VISIBILITY_PRESET hidden
                                               VISIBILITY_INLINES_HIDDEN ON)
  # Link against pthread if needed
  find_package(Threads REQUIRED)
  target_link_libraries(SLOSCParser PRIVATE Threads::Threads)
endif()

# Set output directory
set_target_properties(
  SLOSCParser
  PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
             LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
             ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

# Export symbols for shared library
if(WIN32)
  set_target_properties(SLOSCParser PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

# Install rules
install(
  TARGETS SLOSCParser
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

install(FILES ${HEADERS} DESTINATION include)
