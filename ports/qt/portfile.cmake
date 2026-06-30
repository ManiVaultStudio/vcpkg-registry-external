set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)


# Guard against multiple variant selection in target, opengl and thin

set(TARGET_VARIANTS "target-desktop" "target-android" "target-ios")
set(TARGET_SELECTED "")
set(OPENGL_VARIANTS "opengl-es2" "opengl-desktop" "opengl-dynamic")
set(OPENGL_SELECTED "" )
set(THIN_VARIANTS "thin-arm64" "thin-x86-64" )
set(THIN_SELECTED "")

# setup maps in json string literals using cmake "bracket arguments"
set(VALID_ARCH_STRS
  "win64_msvc2022_64"
  "win32_msvc2019"
  "win64_msvc2019_64"
  "win32_msvc2017"
  "win64_msvc2017_64"
  "win32_msvc2015"
  "win64_msvc2015_64"
  "linux_gcc_64"
  "clang_64"
)

set(MSVC_TOOLSET_MAP [=[
{
    "v140": "msvc2015",
    "v141": "msvc2017",
    "v142": "msvc2019",
    "v143": "msvc2022",
    "v145": "msvc2026"
}
]=])

set(OS_MAP [=[
{
    "Linux": "linux", 
    "Windows": "windows", 
    "Macos": "mac", 
    "iOS": "mac"  
}
]=])

function(get_platform)
  # Set the PLATFORM_NAME in the calling scope
  if (VCPKG_TARGET_IS_WINDOWS)
    set(PLATFORM_NAME "windows" PARENT_SCOPE)
  elseif (VCPKG_TARGET_IS_LINUX)
    set(PLATFORM_NAME "linux" PARENT_SCOPE)
  elseif (VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(PLATFORM_NAME "mac" PARENT_SCOPE)
  else()
    message(FATAL_ERROR "Could not identify platform from VCPKG_TARGET_IS_OSX: ${VCPKG_TARGET_IS_OSX} or VCPKG_TARGET_IS_IOS: ${VCPKG_TARGET_IS_IOS}")
  endif()
endfunction()

function(get_compiler_name)
  # If on Windows translate the VCPKG_PLATFORM_TOOLSET  to a COMPILER_NAME 
  # in the calling scope
  # If not Windows then the compiler name is the empty string
  # Uses the MSVC_TOOLSET_MAP
  # FATAL_ERROR if VCPKG_PLATFORM_TOOLSET  is missing in map.
  set(result "")
  if (VCPKG_TARGET_IS_WINDOWS)
    string(JSON result ERROR_VARIABLE json_error GET "${MSVC_TOOLSET_MAP}" "${VCPKG_PLATFORM_TOOLSET}")
    if(json_error)
      message(FATAL_ERROR "No MSVC version mapping found for ${VCPKG_PLATFORM_TOOLSET}")
    endif()
  endif()
  set(COMPILER_NAME "${result}" PARENT_SCOPE)
endfunction()

function(get_arch_prefix_suffix)
  # Set the variable OS_ARCH_PREFIX and OS_ARCH_SUFFIX in the calling scope
  # based on the OS WIN32, LINUX, MACOS and the void pointer size
  if (CMAKE_SIZEOF_VOID_P EQUAL 4)
    if (VCPKG_TARGET_IS_WINDOWS)
      set(OS_ARCH_PREFIX "win32" PARENT_SCOPE)
    else()
      message(FATAL_ERROR "32-bit architecture ot supported on non-Windows platform")
    endif()
    set(OS_ARCH_SUFFIX "" PARENT_SCOPE)
  else ()
    if (VCPKG_TARGET_IS_WINDOWS)
      set(OS_ARCH_PREFIX "win64" PARENT_SCOPE)
    elseif(VCPKG_TARGET_IS_LINUX)
      set(OS_ARCH_PREFIX "linux_gcc" PARENT_SCOPE)
    elseif(VCPKG_TARGET_IS_OSX)
      set(OS_ARCH_PREFIX "clang" PARENT_SCOPE)
    endif()
    set(OS_ARCH_SUFFIX "64" PARENT_SCOPE)
  endif ()
endfunction()

function(get_arch)
  # Sets the BUILD_ARCH variable in the parent scope
  get_compiler_name()
  get_arch_prefix_suffix()
  if (VCPKG_TARGET_IS_WINDOWS)
    if (OS_ARCH_SUFFIX)
      string(JOIN "_" result "${OS_ARCH_PREFIX}" "${COMPILER_NAME}" "${OS_ARCH_SUFFIX}")
    else()
      string(JOIN "_" result "${OS_ARCH_PREFIX}" "${COMPILER_NAME}")
    endif()
  else()
    string(JOIN "_" result "${OS_ARCH_PREFIX}" "${OS_ARCH_SUFFIX}")
  endif()
  set(BUILD_ARCH "${result}" PARENT_SCOPE)

endfunction()

# Run through the selected features setting and checking the single option
set(SIMPLE_FEATURES "")
list(REMOVE_ITEM FEATURES "core")
message(STATUS "Unparsed feature list: ${FEATURES}")
foreach(variant IN LISTS FEATURES)
  if (variant IN_LIST TARGET_VARIANTS)
    if (TARGET_SELECTED)
      message(FATAL_ERROR "Multiple TARGET versions enabled: ${TARGET_SELECTED} and ${variant}")
    else()
      string(REGEX MATCH "target-(.*)" _unused "${variant}")
      message(STATUS "Target found ${CMAKE_MATCH_1} in ${variant}")
      set(TARGET_SELECTED "${CMAKE_MATCH_1}")
    endif()
  elseif(variant IN_LIST OPENGL_VARIANTS)
    if (OPENGL_SELECTED)
      message(FATAL_ERROR "Multiple OPENGL versions enabled: ${OPENGL_SELECTED} and ${variant}")
    else()
      set(OPENGL_SELECTED "${variant}")
    endif()
  elseif(variant IN_LIST THIN_VARIANTS)
    if (THIN_SELECTED)
      message(FATAL_ERROR "Multiple OPENGL versions enabled: ${THIN_SELECTED} and ${variant}")
    else()
      set(THIN_SELECTED "${variant}")
    endif()
  else()
    list(APPEND SIMPLE_FEATURES "${variant}")
  endif()
endforeach()

# set the BUILD_ARCH variable
get_arch()
# get th PLATFORM_NAME variable
get_platform()

message(STATUS "**************In QT portfile*****************")
# Invoke your Python script — it must deposit files into
# ${CURRENT_PACKAGES_DIR} when done
# python qt-installer.py 6.9.3 windows desktop -a win64_msvc2022_64 -p positioning webchannel webengine virtualkeyboard imageformats datavis3d charts networkauth qt5compat
set(PYTHON3_EXECUTABLE "$ENV{PYTHON3_EXECUTABLE}")
if(NOT PYTHON3_EXECUTABLE)
  message(FATAL_ERROR "PYTHON3_EXECUTABLE environment variable is not set.")
endif()
message(STATUS "Using python at ${PYTHON3_EXECUTABLE}")
#execute_process(
#  COMMAND "${PYTHON3_EXECUTABLE}" -m pip install requests packaging colorama
#  RESULT_VARIABLE pip_result
#)
#if(NOT pip_result EQUAL 0)
#  message(FATAL_ERROR "Failed to install Python 'requests' module")
#endif()
message(STATUS "Run the qt-installer: version: ${VERSION} platform: ${PLATFORM_NAME} target:  ${TARGET_SELECTED} architecture: ${BUILD_ARCH} ")
string(REPLACE ";" " " FEATURE_STRING "${SIMPLE_FEATURES}")
set(ENV{PYTHONDONTWRITEBYTECODE} "1")
execute_process(
  COMMAND "${PYTHON3_EXECUTABLE}" "${CMAKE_CURRENT_LIST_DIR}/qt-installer.py"
          "${VERSION}" "${PLATFORM_NAME}" "${TARGET_SELECTED}"
          "-a" "${BUILD_ARCH}"
          "-p" ${SIMPLE_FEATURES}
  WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
  OUTPUT_VARIABLE installer_output
  ERROR_VARIABLE  installer_error
  RESULT_VARIABLE result
)


  message(STATUS "qt-installer.py stdout: ${installer_output}")
if(NOT result EQUAL 0)
  message(STATUS "qt-installer.py stderr: ${installer_error}")
  message(FATAL_ERROR "qt-installer.py failed for triplet ${VCPKG_TARGET_TRIPLET}")
endif()

file(GLOB QT_ARCH_DIRS "${CURRENT_PACKAGES_DIR}/${VERSION}/*")
foreach(arch_dir ${QT_ARCH_DIRS})
    file(COPY "${arch_dir}/" DESTINATION "${CURRENT_PACKAGES_DIR}")
endforeach()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${VERSION}")

# Fix the ICU file location (needed on Linux) - there are in the root
file(GLOB ICU_LIBS "${CURRENT_PACKAGES_DIR}/libicu*.so*")
if(ICU_LIBS)
    file(COPY ${ICU_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(REMOVE ${ICU_LIBS})
endif()

message(STATUS "*** Validate rpath in installed rcc ***")
execute_process(
    COMMAND otool -l "${CURRENT_PACKAGES_DIR}/libexec/rcc"
    OUTPUT_VARIABLE rcc_check
)
message(STATUS "rcc rpaths: ${rcc_check}")

# vcpkg requires a copyright file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/qt")

if(VCPKG_TARGET_IS_OSX)
  set(CMAKE_INSTALL_RPATH "@loader_path/../Frameworks")
  set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

