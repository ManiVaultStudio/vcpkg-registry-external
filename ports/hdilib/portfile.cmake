set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "biovault/HDILib"
  REF "v${VERSION}" 
  SHA512 "D830AA14CEFB5728D39489EA980B0F864E1B154F194A868215AE15729C5C9E10912F078C914C34A37DC1DA46D6F0F7671FF989FC5AB3969181154B33E59257DC"
#  PATCHES
#    fix-flann-target.patch
)

execute_process(COMMAND powershell -Command "Get-ChildItem -Filter glslangValidator.exe -Recurse $pwd" 
  RESULT_VARIABLE _copy_result
  OUTPUT_VARIABLE _copy_output
  ERROR_VARIABLE _copy_error
)

message(STATUS "Copy output: ${_copy_output}")
message(STATUS "Copy error: ${_copy_error}")
vcpkg_cmake_configure( SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
  -DCMAKE_BUILD_TYPE=Release
  -DSUPPORT_LIBS_INSTALL=OFF
  -DENABLE_TESTS=OFF
  -DHDILib_BUILD_TESTS=OFF
  -DFETCHCONTENT_FULLY_DISCONNECTED=OFF
  -DVulkan_GLSLC_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/shaderc/glslc.exe
  -DVulkan_GLSLANG_VALIDATOR_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/glslang/glslangValidator.exe

  )

vcpkg_cmake_install()

  # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")