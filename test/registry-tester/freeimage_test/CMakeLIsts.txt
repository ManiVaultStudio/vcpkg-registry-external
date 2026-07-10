cmake_minimum_required(VERSION 3.25)
set(PROJECT_NAME registry-tester-freeimage)
project(${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(FreeImage REQUIRED)

add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT} PRIVATE FreeImage)
