set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "biovault/FreeImage"
  REF "v${VERSION}" 
  SHA512 "726449AB32BEEAF14B3F56D0274474E9859A70335213AD13791EDC3DC17D31378FE00732B3E232B2FA8316B83676C5A394A9E5419C6B1C8F3A4077EE543B7331"
)


# Remove /permissive- for OpenEXR and FreeImage
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(OpenEXR PRIVATE /permissive)
    target_compile_options(FreeImage PRIVATE /permissive)
    target_compile_options(FreeImageLib PRIVATE /permissive) # we don't need the static library, but just in case someone does build it
endif()

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")