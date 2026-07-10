set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "biovault/FreeImage"
  REF "v${VERSION}" 
  SHA512 "a7e8f289b2123b2f9919b0b2947940665fd373fd348d16a352db46e23c96ae73812dbba7fc7832b95cbadbedb3085f6f44628ae126d24bf30098aa077c1ccf3e"
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
  -DCMAKE_BUILD_TYPE=Release)


# Remove /permissive- for OpenEXR and FreeImage
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(OpenEXR PRIVATE /permissive)
    target_compile_options(FreeImage PRIVATE /permissive)
    target_compile_options(FreeImageLib PRIVATE /permissive) # we don't need the static library, but just in case someone does build it
endif()

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")