set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)


# Guard against multiple variant selection in target, opengl and thin

set(TARGET_VARIANTS "target-desktop" "target-android" "target-ios")
set(TARGET_SELECTED "")
set(OPENGL_VARIANTS "opengl-es2" "opengl-desktop" "opengl-dynamic")
set(OPENGL_SELECTED "" )
set(THIN_VARIANTS "thin-arm64" "thin-x86_64" )
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
    "140": "msvc2015",
    "141": "msvc2017",
    "142": "msvc2019",
    "143": "msvc2022",
    "145": "msvc2026"
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
    set(PLATFORM_NAME "mac")
  endif()
endfunction()

function(get_compiler_name)
  # If on Windows translate the MSVC_TOOLSET_VERSION to a COMPILER_NAME 
  # in the calling scope
  # If not Windows then the compiler name is the empty string
  # Uses the MSVC_TOOLSET_MAP
  # FATAL_ERROR if MSVC_TOOLSET_VERSION is missing in map.
  set(result "")
  if (VCPKG_TARGET_IS_WINDOWS)
    string(JSON result ERROR_VARIABLE json_error GET "${MSVC_TOOLSET_MAP}" "${MSVC_TOOLSET_VERSION}")
    if(json_error)
      message(FATAL_ERROR "No MSVC version mapping found for ${MSVC_TOOLSET_VERSION}")
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
      string(JOIN "_" result "$OS_ARCH_PREFIX" "$COMPILER_NAME" "$OS_ARCH_SUFFIX")
    else()
      string(JOIN "_" result "$OS_ARCH_PREFIX" "$COMPILER_NAME")
    endif()
  else()
    string(JOIN "_" result "$OS_ARCH_PREFIX" "$OS_ARCH_SUFFIX")
  endif()
  set(BUILD_ARCH "$result" PARENT_SCOPE)

endfunction()

# Run through the selected features setting and checking the single option
set(SIMPLE_FEATURES "")
foreach(variant IN LISTS FEATURES)
  if (variant IN_LIST TARGET_VARIANTS)
    if (TARGET_SELECTED)
      message(FATAL_ERROR "Multiple TARGET versions enabled: ${TARGET_SELECTED} and ${variant}")
    else()
      set(TARGET_SELECTED "${variant}")
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

# Invoke your Python script — it must deposit files into
# ${CURRENT_PACKAGES_DIR} when done
find_package(Python3 REQUIRED)
# python qt-installer.py 6.9.3 windows desktop -a win64_msvc2022_64 -p positioning webchannel webengine virtualkeyboard imageformats datavis3d charts networkauth qt5compat
execute_process(
  COMMAND "${Python3_EXECUTABLE}" "${CMAKE_CURRENT_LIST_DIR}/qt-installer.py"
          "${VERSION}" "${PLATFORM_NAME}" "desktop"
          "-a" "${BUILD_ARCH}" "
          "-p" "${TARGET_SELECTED}" "${OPENGL_SELECTED}" "${SIMPLE_FEATURES}
  RESULT_VARIABLE result
)

if(NOT result EQUAL 0)
  message(FATAL_ERROR "qt-installer.py failed for triplet ${VCPKG_TARGET_TRIPLET}")
endif()

# vcpkg requires a copyright file
#file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright"
#     DESTINATION "${CURRENT_PACKAGES_DIR}/share/mylib")