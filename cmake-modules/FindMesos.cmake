#
# Locate the Mesos library.
#
# Defines the following variables:
#
#   Mesos_FOUND - Found the Mesos library.
#   Stout_INCLUDE_DIR - Stout include folder.
#   Libprocess_INCLUDE_DIR - Libprocess include folder.
#   Mesos_INCLUDE_DIR - Mesos public headers.
#   Mesos_LIBRARIES - libmesos.
#
# Accepts the following variables as input:
#
#   Mesos_ROOT - (as an environment variable) The root directory of Mesos.
#
# Example Usage:
#
#    # Don't forget to provide CMake with the path to this file.
#    # For example, if you put this file into <your_project_root>/cmake-modules,
#    # the following command will make it visible to CMake.
#    SET (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)
#
#    FIND_PACKAGE (Mesos REQUIRED)
#    INCLUDE_DIRECTORIES (${Mesos_INCLUDE_DIR} ${Stout_INCLUDE_DIR} ${Libprocess_INCLUDE_DIR})
#
#    ADD_EXECUTABLE (MesosFramework scheduler.cpp)
#    TARGET_LINK_LIBRARIES (MesosFramework ${Mesos_LIBRARIES})
#

# Finds particular version (debug | release, .a | .so) of Mesos.
FUNCTION (FindMesosLibrary libvar libname)
    FIND_LIBRARY (${libvar}
        NAMES ${libname}
        HINTS $ENV{MESOS_ROOT} ${Mesos_BUILD_DIR}/src
        PATH_SUFFIXES lib64 ./libs
    )

    # This shows the variable only in the advanced mode of cmake-gui.
    MARK_AS_ADVANCED (${libvar})
ENDFUNCTION (FindMesosLibrary libvar libname)

# Find Mesos root folder, which contains "include/mesos/mesos.proto" file.
FIND_PATH (Mesos_ROOT_DIR include/mesos/mesos.proto
    HINTS $ENV{MESOS_ROOT}/include
)
MARK_AS_ADVANCED (Mesos_ROOT_DIR)

# Find Mesos build folder.
FIND_PATH (Mesos_BUILD_DIR mesos-master
    HINTS $ENV{MESOS_ROOT}/build
)
IF ("${Mesos_BUILD_DIR}" MATCHES "-NOTFOUND")
    FIND_PATH (Mesos_BUILD_DIR mesos
        HINTS $ENV{MESOS_ROOT}/build
    )
ENDIF()
MARK_AS_ADVANCED (Mesos_BUILD_DIR)

# Locate release and debug versions of the library.
FindMesosLibrary(Mesos_LIBRARY mesos)

# Use the standard CMake tool to handle FIND_PACKAGE() options and set the
# MESOS_FOUND variable.
INCLUDE (${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS (Mesos DEFAULT_MSG
    Mesos_ROOT_DIR
    Mesos_BUILD_DIR
    Mesos_LIBRARY
)

# Define variable Mesos_FOUND additionally to MESOS_FOUND for consistency.
SET (Mesos_FOUND MESOS_FOUND)

# If we found mesos, define some additional variables
if (DEFINED MESOS_FOUND)
    set(Mesos_INCLUDE_DIR ${Mesos_ROOT_DIR}/include)

    # Read mesos.pb.h and extract the minimum protobuf version required
    file(READ "${Mesos_INCLUDE_DIR}/mesos/mesos.pb.h" _PROTO_H_CONTENTS)
    string(REGEX MATCH "GOOGLE_PROTOBUF_VERSION < [0-9]+" _MESOS_PROTOBUF ${_PROTO_H_CONTENTS})
    string(SUBSTRING ${_MESOS_PROTOBUF} 26 -1 _MESOS_PROTOBUF)
    string(SUBSTRING ${_MESOS_PROTOBUF} 0 3 Mesos_PROTOBUF_MAJOR)
    string(SUBSTRING ${_MESOS_PROTOBUF} 3 3 Mesos_PROTOBUF_MINOR)
    string(REGEX REPLACE "0+$" "" Mesos_PROTOBUF_MAJOR ${Mesos_PROTOBUF_MAJOR} )
    string(REGEX REPLACE "0+$" "" Mesos_PROTOBUF_MINOR ${Mesos_PROTOBUF_MINOR} )

    # Do not pollute namespace with temporary variables
    unset(_PROTO_H_CONTENTS)
    unset(_MESOS_PROTOBUF)
endif()
