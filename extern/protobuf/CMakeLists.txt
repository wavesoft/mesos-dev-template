cmake_minimum_required(VERSION 2.6.2 FATAL_ERROR)
project( protobuf C )

# Download information for CURL
if ( NOT DEFINED PROTOBUF_VERSION )
    message( FATAL_ERROR "PROTOBUF_VERSION version was not definedd" )
endif()

#############################################################
# DOWNLOAD BOOTSTRAP
#############################################################

# Setup archive
set( ARCHIVE_URL  "https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz" )
set( ARCHIVE_DIR  "${CMAKE_BINARY_DIR}/extern/protobuf-src-${PROTOBUF_VERSION}" )
set( ARCHIVE_EXT  ".tar.gz" )

# Check if we have the archive
if ( NOT EXISTS ${ARCHIVE_DIR} )
  set( ARCHIVE_FILE "${ARCHIVE_DIR}${ARCHIVE_EXT}" )

    # Make the directory
    FILE( MAKE_DIRECTORY ${ARCHIVE_DIR} )

    # Download the archive
    message( STATUS "Downloading ${PROJECT_NAME} archive" )
    file(DOWNLOAD ${ARCHIVE_URL} ${ARCHIVE_FILE}
        SHOW_PROGRESS STATUS ARCHIVE_DOWNLOAD_STATUS)

    # Check status
    list( GET ARCHIVE_DOWNLOAD_STATUS 0 ARCHIVE_DOWLOAD_ERROR )
    if( ARCHIVE_DOWLOAD_ERROR )

        # Remove file and dir
        file( REMOVE ${ARCHIVE_FILE} )
        file( REMOVE_RECURSE ${ARCHIVE_DIR} )

        # Fatal error
        message( FATAL_ERROR "Could not download ${PROJECT_NAME} archive!" )
    endif()

    # Extract archive
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_FILE}
        WORKING_DIRECTORY ${ARCHIVE_DIR}
    )

endif()

# Get the first sub-directory in the archive
FILE(GLOB _ARCHIVE_SUBDIRS ${ARCHIVE_DIR}/*)
FOREACH( _ARCHIVE_SUBDIR ${_ARCHIVE_SUBDIRS} )
    IF(IS_DIRECTORY ${_ARCHIVE_SUBDIR})
        SET(ARCHIVE_DIR ${_ARCHIVE_SUBDIR})
    ENDIF()
ENDFOREACH()

# Prepare directories
set( PROTOBUF_SOURCE_DIR ${ARCHIVE_DIR} )
set( PROTOBUF_BIN_DIR ${CMAKE_BINARY_DIR}/protobuf_bin )

# Expose project variables to parent
set (PROTOBUF_LIBRARIES "libprotobuf.la" PARENT_SCOPE)
set (PROTOBUF_INCLUDE_DIRS ${PROTOBUF_BIN_DIR}/include PARENT_SCOPE)

#############################################################
# BUILD SCRIPT
#############################################################

ExternalProject_Add(protobuf
    SOURCE_DIR ${PROTOBUF_SOURCE_DIR}
    CONFIGURE_COMMAND ${PROTOBUF_SOURCE_DIR}/configure --prefix=${PROTOBUF_BIN_DIR}
    PATCH_COMMAND ./autogen.sh
    BUILD_COMMAND ${MAKE})
