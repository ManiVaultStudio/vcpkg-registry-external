set(VCPKG_BUILD_TYPE release)  # pre-built, no debug variant
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "biovault/FreeImage"
  REF "v${VERSION}" 
  SHA512 "a7e8f289b2123b2f9919b0b2947940665fd373fd348d16a352db46e23c96ae73812dbba7fc7832b95cbadbedb3085f6f44628ae126d24bf30098aa077c1ccf3e"
)

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

if(VERSION MATCHES "^([0-9]+\\.[0-9]+\\.[0-9]+)")
    set(FREEIMAGE_VERSION_3_DIGIT "${CMAKE_MATCH_1}")
else()
    # Fallback just in case the format is unexpected
    set(FREEIMAGE_VERSION_3_DIGIT "3.19.0") 
endif()

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

if(NOT WIN32 AND NOT APPLE)
    set(RELEASE_SO_FILE "libFreeImage.so.${FREEIMAGE_VERSION_3_DIGIT}")
    
    # Symlink the shared library right next to the versioned file in bin/
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${RELEASE_SO_FILE}" AND NOT EXISTS "${CURRENT_PACKAGES_DIR}/bin/libFreeImage.so")
        file(CREATE_LINK "${RELEASE_SO_FILE}" "${CURRENT_PACKAGES_DIR}/bin/libFreeImage.so" SYMBOLIC)
    endif()
    
    # Repeat for Debug configurations
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${RELEASE_SO_FILE}" AND NOT EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/libFreeImage.so")
        file(CREATE_LINK "${RELEASE_SO_FILE}" "${CURRENT_PACKAGES_DIR}/debug/bin/libFreeImage.so" SYMBOLIC)
    endif()
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
set(freeimage_VERSION \"${FREEIMAGE_VERSION_3_DIGIT}\")
set(FreeImage_VERSION \"${FREEIMAGE_VERSION_3_DIGIT}\")

# Define cross-platform filenames based on your build setup
if(WIN32)
    set(SHARED_LIB \"bin/FreeImage.lib\") # Import library for DLL
    set(STATIC_LIB \"lib/FreeImageLib.lib\")
elseif(APPLE)
    set(SHARED_LIB \"bin/libFreeImage.dylib\")
    set(STATIC_LIB \"lib/libFreeImageLib.a\")
else()
    # Linux / Unix
    set(SHARED_LIB \"bin/libFreeImage.so\")
    set(STATIC_LIB \"lib/libFreeImageLib.a\")
endif()

# ----------------------------------------------------
# Target 1: Shared Library (freeimage::freeimage)
# ----------------------------------------------------
if(EXISTS \"\${CMAKE_CURRENT_LIST_DIR}/../../\${SHARED_LIB}\")
    if(NOT TARGET freeimage::freeimage)
        add_library(freeimage::freeimage UNKNOWN IMPORTED)
        set_target_properties(freeimage::freeimage PROPERTIES
            IMPORTED_LOCATION_RELEASE \"\${CMAKE_CURRENT_LIST_DIR}/../../\${SHARED_LIB}\"
            IMPORTED_LOCATION_DEBUG \"\${CMAKE_CURRENT_LIST_DIR}/../../debug/\${SHARED_LIB}\"
            INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
        )
    endif()
endif()

# ----------------------------------------------------
# Target 2: Static Library (freeimage::freeimage-static)
# ----------------------------------------------------
if(EXISTS \"\${CMAKE_CURRENT_LIST_DIR}/../../\${STATIC_LIB}\")
    if(NOT TARGET freeimage::freeimage-static)
        add_library(freeimage::freeimage-static STATIC IMPORTED)
        set_target_properties(freeimage::freeimage-static PROPERTIES
            IMPORTED_LOCATION_RELEASE \"\${CMAKE_CURRENT_LIST_DIR}/../../\${STATIC_LIB}\"
            IMPORTED_LOCATION_DEBUG \"\${CMAKE_CURRENT_LIST_DIR}/../../debug/\${STATIC_LIB}\"
            INTERFACE_INCLUDE_DIRECTORIES \"\${CMAKE_CURRENT_LIST_DIR}/../../include\"
        )
    endif()
    
    # Alias to fallback seamlessly if a consumer drops \"-static\" but wants the static target
    if(NOT TARGET freeimage::freeimage)
        add_library(freeimage::freeimage INTERFACE IMPORTED)
        set_target_properties(freeimage::freeimage PROPERTIES
            INTERFACE_LINK_LIBRARIES freeimage::freeimage-static
        )
    endif()
endif()
")

# Write both filenames to ensure cross-platform compatibility
file(WRITE "${CURRENT_PACKAGES_DIR}/share/freeimage/freeimageConfig.cmake" "${CONFIG_CONTENT}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/freeimage/FreeImageConfig.cmake" "${CONFIG_CONTENT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license-fi.txt")