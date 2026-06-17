vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "biovault/biovault_bfloat16"
  REF "v${VERSION}" 
  SHA512 "31026D40078CA0B29447D18E1FF98198585A6E7052B377E08B1D5397A5967DAD5B8061502D052C69C0702283A3FAEA74A514203FC03C50FB678BBE5856AB4497"
)

# This is a header only library
file(INSTALL "${SOURCE_PATH}/biovault_bfloat16.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/bfloat16")

# Install a CMake config so find_package(biovault_bfloat16) works
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/biovault_bfloat16-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/biovault_bfloat16-config.cmake"
    @ONLY
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")