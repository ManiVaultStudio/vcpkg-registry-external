#set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "biovault/HDILib"
  REF "v${VERSION}" 
  SHA512 "D830AA14CEFB5728D39489EA980B0F864E1B154F194A868215AE15729C5C9E10912F078C914C34A37DC1DA46D6F0F7671FF989FC5AB3969181154B33E59257DC"
#  PATCHES
#    fix-flann-target.patch
)


find_file(result  NAMES "glslangValidator${VCPKG_HOST_EXECUTABLE_SUFFIX}" PATHS ${CURRENT_HOST_INSTALLED_DIR}/tools/glslang)
message(STATUS "Found glslangValidator: ${result}")

# Inject the glslangValidator and glslc executables into the PATH so that HDILib can find them
# in the vulkan_compile_shader_13() function. This uses find_program() which will not work
# in this instance unless the paths are added to the environment.
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glslang")
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/shaderc")

if(VCPKG_TARGET_IS_OSX)
    # Homebrew libomp does not install to a standard path on macOS
    execute_process(
        COMMAND brew --prefix libomp
        OUTPUT_VARIABLE HOMEBREW_LIBOMP_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(OPENMP_OPTIONS
        -DOpenMP_C_FLAGS=-I${HOMEBREW_LIBOMP_PREFIX}/include
        -DOpenMP_CXX_FLAGS=-I${HOMEBREW_LIBOMP_PREFIX}/include
        -DOpenMP_C_LIB_NAMES=omp
        -DOpenMP_CXX_LIB_NAMES=omp
        -DOpenMP_omp_LIBRARY=${HOMEBREW_LIBOMP_PREFIX}/lib/libomp.dylib
    )
else()
    set(OPENMP_OPTIONS "")
endif()

vcpkg_cmake_configure( SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
  -DCMAKE_BUILD_TYPE=Release
  -DSUPPORT_LIBS_INSTALL=OFF
  -DENABLE_TESTS=OFF
  -DHDILib_BUILD_TESTS=OFF
  -DFETCHCONTENT_FULLY_DISCONNECTED=OFF
  -DVulkan_GLSLC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/shaderc/glslc${VCPKG_HOST_EXECUTABLE_SUFFIX}
  -DVulkan_GLSLANG_VALIDATOR_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/glslang/glslangValidator${VCPKG_HOST_EXECUTABLE_SUFFIX}
  ${OPENMP_OPTIONS}
  )

vcpkg_cmake_install()

  # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")