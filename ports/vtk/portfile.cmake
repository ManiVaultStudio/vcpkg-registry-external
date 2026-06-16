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

# set the BUILD_ARCH variable
get_arch()
# get th PLATFORM_NAME variable
get_platform()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO "Kitware/VTK"
  REF "v${VERSION}" 
  SHA512 "525E97759CADFB1DFA0473E1E856E1AE19C46CF7CD515322079CFED1B1F36BBAAA2A8B3DA8E0D607ACC569EF6EE1D42A75A30BEE459582730F22FF2CBECB60B8"
)

set(VCPKG_BUILD_TYPE release)

vcpkg_check_features(OUT_FEATURE_OPTIONS VTK_FEATURE_OPTIONS
  FEATURES
    "qt" VTK_GROUP_ENABLE_Qt
    "qt" VTK_MODULE_ENABLE_VTK_GUISupportQt
    "qt" VTK_MODULE_ENABLE_VTK_RenderingQt
    "qt" VTK_MODULE_ENABLE_VTK_ViewsQt
    "qt" VTK_QT_VERSION
    "mpi" VTK_Group_MPI
    "mpi" Module_vtkIOParallelXML
    "ioxml" Module_vtkIOXML
    "ioexport" Module_vtkIOExport
    "ioxdmf3" Module_vtkIOXdmf3
    "iolegacy" Module_vtkIOLegacy
    "mpi-minimal" Module_vtkIOParallelXML 
    "mpi-minimal" Module_vtkParallelMPI 
)

vcpkg_check_features(OUT_FEATURE_OPTIONS VTK_FEATURE_OPTIONS
    INVERTED_FEATURES
    "qt" VTK_MODULE_ENABLE_VTK_GUISupportQtQuick
    "qt" VTK_MODULE_ENABLE_VTK_GUISupportQtSQL
    "qt" VTK_BUILD_QT_DESIGNER_PLUGIN
    "minimal" VTK_Group_StandAlone
    "minimal" VTK_Group_Rendering
    "basic-viewer" VTK_Group_StandAlone
    "basic-viewer" VTK_Group_Rendering
    "basic-viewer" VTK_ENABLE_WRAPPING
    "basic-viewer" VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore
    "basic-viewer" VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel
    "basic-viewer" VTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters
    "basic-viewer" VTK_MODULE_ENABLE_VTK_DomainsChemistry 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_DomainsChemistryOpenGL2
    "basic-viewer" VTK_MODULE_ENABLE_VTK_DomainsMicroscopy 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_DomainsParallelChemistry
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersAMR 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersFlowPaths 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersGeneric 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersHyperTree 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersOpenTURNS 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersParallelDIY2 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersParallelFlowPaths
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersParallelGeometry
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersParallelImaging 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersParallelMPI 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersParallelStatistics
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersParallelVerdict
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersPoints
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersProgrammable
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersReebGraph
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersSMP
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersSelection
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersTopology
    "basic-viewer" VTK_MODULE_ENABLE_VTK_FiltersVerdict
    "basic-viewer" VTK_MODULE_ENABLE_VTK_GUISupportMFC
    "basic-viewer" VTK_MODULE_ENABLE_VTK_GeovisCore
    "basic-viewer" VTK_MODULE_ENABLE_VTK_GeovisGDAL
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOADIOS2
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOAMR
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOAsynchronous
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOCGNSReader
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOCONVERGECFD
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOChemistry
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOCityGML
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOEnSight
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOExodus
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOExport
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOExportGL2PS
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOExportPDF
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOFFMPEG
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOFides
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOGDAL
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOGeoJSON
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOGeometry
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOH5Rage
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOH5part
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOHDF
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOIOSS
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOImport
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOInfovis
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOLAS
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOLSDyna
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOLegacy
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOMINC
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOMPIImage
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOMotionFX
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOMovie
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOMySQL
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IONetCDF
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOODBC
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOOMF
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOOggTheora
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOOpenVDB
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOPDAL
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOPIO
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOPLY
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOParallel
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOParallelExodus
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOParallelLSDyna
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOParallelNetCDF
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOParallelXML
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOParallelXdmf3T
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOPostgreSQL
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOSQL
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOSegY
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOTRUCHAS
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOTecplotTable
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOVPIC
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOVeraOut
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOVideo
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOXdmf2
    "basic-viewer" VTK_MODULE_ENABLE_VTK_IOXdmf3
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ImagingFourier
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ImagingHybrid
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ImagingMorphological
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ImagingOpenGL2
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ImagingSources
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ImagingStencil
    "basic-viewer" VTK_MODULE_ENABLE_VTK_InfovisBoost
    "basic-viewer" VTK_MODULE_ENABLE_VTK_InfovisBoostGraphAlgorithms
    "basic-viewer" VTK_MODULE_ENABLE_VTK_InfovisCore
    "basic-viewer" VTK_MODULE_ENABLE_VTK_InfovisLayout
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ParallelCore
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ParallelDIY
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ParallelMPI
    "basic-viewer" VTK_MODULE_ENABLE_VTK_PythonInterpreter
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingExternal
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingFFMPEGOpenGL2
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingFreeTypeFontConfig
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingImage
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingLICOpenGL2
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingLODDO
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingLabel
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingMatplotlib
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingOpenVR 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingParallel 
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingParallelLIC
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingRayTracing
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingSceneGraph
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingVRDON
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingVolumeAMR
    "basic-viewer" VTK_MODULE_ENABLE_VTK_RenderingVtkJS
    "basic-viewer" VTK_MODULE_ENABLE_VTK_TestingCoreDON
    "basic-viewer" VTK_MODULE_ENABLE_VTK_TestingGenericBridge
    "basic-viewer" VTK_MODULE_ENABLE_VTK_TestingIOSQLDO
    "basic-viewer" VTK_MODULE_ENABLE_VTK_TestingRendering
    "basic-viewer" VTK_MODULE_ENABLE_VTK_UtilitiesBenchmarks
    "basic-viewer" VTK_MODULE_ENABLE_VTK_ViewsContext2D
    "basic-viewer" VTK_MODULE_ENABLE_VTK_WebCoreDONT_WA
    "basic-viewer" VTK_MODULE_ENABLE_VTK_WebGLExporterD
    "basic-viewer" VTK_MODULE_ENABLE_VTK_WrappingPythonCore
    "basic-viewer" VTK_MODULE_ENABLE_VTK_WrappingToolsD
)

# Replace common value to vtk value
list(TRANSFORM VTK_FEATURE_OPTIONS REPLACE "=ON" "=YES")
list(TRANSFORM VTK_FEATURE_OPTIONS REPLACE "=OFF" "=DONT_WANT")

vcpkg_cmake_configure( SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS 
  ${VTK_FEATURE_OPTIONS}
  -DVTK_QT_VERSION=6
  -DBUILD_TESTING=OFF
  -DVTK_BUILD_TESTING=OFF
  -DVTK_BUILD_EXAMPLES=OFF
  -DVTK_ENABLE_REMOTE_MODULES=OFF)


vcpkg_cmake_install()

# vcpkg requires a copyright file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/copyright"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/qt")

if(VCPKG_TARGET_IS_OSX)
  set(CMAKE_INSTALL_RPATH "@loader_path/../Frameworks")
  set(VCPKG_FIXUP_MACHO_RPATH OFF)
endif()

