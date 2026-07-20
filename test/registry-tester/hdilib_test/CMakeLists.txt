cmake_minimum_required(VERSION 3.25)
set(PROJECT_NAME registry-tester-hdilib)
# Restrict to Release only to match vcpkg's release-only binaries
set(CMAKE_CONFIGURATION_TYPES "Release" CACHE STRING "Build configurations" FORCE)

project(${PROJECT_NAME})
#set(VCPKG_BUILD_TYPE release)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Map RelWithDebInfo and MinSizeRel to Release vcpkg binaries
set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release)
set(CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL Release)

find_package(lz4 CONFIG REQUIRED)
find_package(flann CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(kompute CONFIG REQUIRED)
find_package(glfw3 REQUIRED)
find_package(OpenGL REQUIRED)

find_package(OpenMP)
find_package(HDILib COMPONENTS hdidimensionalityreduction hdiutils hdidata CONFIG REQUIRED)

add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE 
  ${HDILib_LINK_LIBS}
  OpenGL::GL)
target_include_directories(${PROJECT_NAME} PRIVATE ${HDILib_INCLUDE_DIR})
# Force the test executable to use the Dynamic CRT (/MD) to match vcpkg
set_target_properties(${PROJECT_NAME} PROPERTIES
    MSVC_RUNTIME_LIBRARY "MultiThreadedDLL"
)
#  Force Iterator Debug Level to 0 and remove _DEBUG definitions 
#  so it matches the vcpkg Release library layout perfectly
target_compile_definitions(registry-tester-hdilib PRIVATE 
        $<$<CONFIG:Debug>:_ITERATOR_DEBUG_LEVEL=0>
        $<$<CONFIG:Debug>:NDEBUG>
    )
# For fmt - used by kompute for logging
target_compile_options(${PROJECT_NAME} PRIVATE $<$<CXX_COMPILER_ID:MSVC>:/utf-8>)