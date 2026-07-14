set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "biovault/FreeImage"
  REF "v${VERSION}" 
  SHA512 "a7e8f289b2123b2f9919b0b2947940665fd373fd348d16a352db46e23c96ae73812dbba7fc7832b95cbadbedb3085f6f44628ae126d24bf30098aa077c1ccf3e"
)

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

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

function(install_freeimage_libs config_suffix package_subdir)
    # Find all static libs, shared libs, and import libs in this build directory
    file(GLOB_RECURSE BUILT_LIBS 
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config_suffix}/*.lib"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config_suffix}/*.dll"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config_suffix}/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config_suffix}/*.so*"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${config_suffix}/*.dylib"
    )

    foreach(lib_file IN LISTS BUILT_LIBS)
        # Determine if it's a runtime DLL/shared lib or a static/import lib
        if(lib_file MATCHES "\\.(dll|so|dylib)$")
            # Runtime binaries go to /bin or /debug/bin
            file(INSTALL "${lib_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/${package_subdir}bin")
        else()
            # Static/Import libs (.lib, .a) go to /lib or /debug/lib
            file(INSTALL "${lib_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/${package_subdir}lib")
        endif()
    endforeach()
endfunction()

# Perform the installation for both Release and Debug libs
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    install_freeimage_libs("rel" "")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    install_freeimage_libs("dbg" "debug/")
endif()

# Perform header install
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

file(INSTALL ${HEADER_FILES}
     DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Create the share directory first to prevent write errors
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/freeimage")

# Define the configuration logic
set(CONFIG_CONTENT "
add_library(freeimage::freeimage UNKNOWN IMPORTED)

# Handle cross-platform library extensions
if(WIN32)
    set(LIB_EXT \".lib\")
elseif(APPLE)
    set(LIB_EXT \".dylib\")
else()
    set(LIB_EXT \".so\")
endif()

set_target_properties(freeimage::freeimage PROPERTIES
    IMPORTED_LOCATION_RELEASE \"\${CMAKE_CURRENT_LIST_DIR}/../../lib/FreeImage\${LIB_EXT}\"
    IMPORTED_LOCATION_DEBUG \"\${CMAKE_CURRENT_LIST_DIR}/../../debug/lib/FreeImage\${LIB_EXT}\"
    INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
)
")

# Write both filenames to ensure cross-platform compatibility
file(WRITE "${CURRENT_PACKAGES_DIR}/share/freeimage/freeimageConfig.cmake" "${CONFIG_CONTENT}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/freeimage/FreeImageConfig.cmake" "${CONFIG_CONTENT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license-fi.txt")