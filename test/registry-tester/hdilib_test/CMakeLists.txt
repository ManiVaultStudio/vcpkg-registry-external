cmake_minimum_required(VERSION 3.25)
set(PROJECT_NAME registry-tester-hdilib)
project(${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(lz4 CONFIG REQUIRED)
find_package(flann CONFIG REQUIRED)
find_package(HDILib COMPONENTS hdidimensionalityreduction hdiutils hdidata CONFIG REQUIRED)

add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${HDILib_LINK_LIBS})