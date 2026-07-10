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

  # We happily use the internal libraries

# Remove /permissive- for OpenEXR and FreeImage
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(OpenEXR PRIVATE /permissive)
    target_compile_options(FreeImage PRIVATE /permissive)
    target_compile_options(FreeImageLib PRIVATE /permissive) # we don't need the static library, but just in case someone does build it
endif()

vcpkg_cmake_build()
vcpkg_cmake_config_fixup()

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(FI_TARGET_LIST FreeImage FreeImageLib LibJPEG.dll LibJXR LibOpenJPEG LibPNG LibRaw LibTIFF4 LibWebP OpenEXR ZLibFreeImage)
else()
  set(FI_TARGET_LIST libFreeImage libFreeImageLib libLibJPEG libLibJXR libLibOpenJPEG libLibPNG libLibRaw libLibTIFF4 libLibWebP libOpenEXR libZLibFreeImage)
endif()

foreach(target IN LISTS FI_TARGET_LIST)
  file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${target}"
      DESTINATION "${CURRENT_PACKAGES_DIR}/lib" PATTERN "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${target}.*")
endforeach()
set( HEADER_FILES
	${SOURCE_PATH}/Source/CacheFile.h
	${SOURCE_PATH}/Source/FreeImage.h
	${SOURCE_PATH}/Source/FreeImageIO.h
	${SOURCE_PATH}/Source/MapIntrospector.h
	${SOURCE_PATH}/Source/Plugin.h
	${SOURCE_PATH}/Source/Quantizers.h
	${SOURCE_PATH}/Source/ToneMapping.h
	${SOURCE_PATH}/Source/Utilities.h
	${SOURCE_PATH}/Source/Metadata/FIRational.h
	${SOURCE_PATH}/Source/Metadata/FreeImageTag.h
	${SOURCE_PATH}/Source/FreeImage/PSDParser.h
	${SOURCE_PATH}/Source/FreeImage/J2KHelper.h
)

file(INSTALL "${HEADER_FILES}"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license-fi.txt")