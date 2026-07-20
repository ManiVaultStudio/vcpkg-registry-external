cmake_minimum_required(VERSION 3.25)
set(PROJECT_NAME registry-tester-vtk)
# Restrict to Release only to match vcpkg's release-only binaries
set(CMAKE_CONFIGURATION_TYPES "Release" CACHE STRING "Build configurations" FORCE)

project(${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Map RelWithDebInfo and MinSizeRel to Release vcpkg binaries
set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release)
set(CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL Release)

find_package(VTK COMPONENTS 
    CommonColor
    CommonCore
    FiltersSources
    RenderingCore 
REQUIRED)

add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${VTK_LIBRARIES})