# - Find PNG for Hugin 0.7 01Nov2007 TKSharpless
# Added to support Windows build but should work anywhere.
# After looking in UNIX standard places, tries wxWidgets build 
# tree, which should have this package.
#
# Call FIND_PACKAGE(wxWidgets REQUIRED) before calling this!
# 
# reads cache variables
#  wxWidgets_ROOT_DIR
#  wxWidgets_LIB_DIR
# defines cache variables
#  PNG_INCLUDE_DIR, where to find headers
#  PNG_LIBRARIES, list of release link libraries.
#  PNG_FOUND, If != "YES", do not try to use PNG.
# None of the above will be defined unless ZLIB can be found

INCLUDE(FindZLIB)

include(FindLibraryWithDebug)

SET(PNG_FOUND "NO")

IF (ZLIB_FOUND)
  FIND_PATH(PNG_INCLUDE_DIR png.h
    /usr/local/include
    /usr/include
    ${SOURCE_BASE_DIR}/libpng/include
  )

  find_library_with_debug(PNG_LIBRARIES
    WIN32_DEBUG_POSTFIX d
    NAMES png libpng libpng15 libpng15_static
    PATHS ${SYSTEM_LIB_DIRS} ${SOURCE_BASE_DIR}/libpng/lib
  )

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(PNG DEFAULT_MSG 
                                  PNG_INCLUDE_DIR PNG_LIBRARIES)

  SET(PNG_LIBRARIES ${PNG_LIBRARIES} ${ZLIB_LIBRARIES})
  MARK_AS_ADVANCED(PNG_INCLUDE_DIR PNG_LIBRARIES )
ENDIF(ZLIB_FOUND)

