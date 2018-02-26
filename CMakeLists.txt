project( mesos-iot-executor )
cmake_minimum_required(VERSION 2.8.4)
cmake_policy(SET CMP0042 NEW)

# Include custom cmake modules
include(ExternalProject)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)

# Mesos 1.5.x is compiled with protobuf headers of version 3.5
# To target other mesos versions you should modify this
set( PROTOBUF_VERSION  3.5.1.1 CACHE STRING "The protobuf version to use" )

#############################################################
# LIBRARIES
#############################################################

#
# [Boost] Mesos bindings requires boost
#
find_package(Boost REQUIRED)
include_directories( ${Boost_INCLUDE_DIRS} )

#
# [Glog] Mesos bindings requires glog
#
find_package(Glog REQUIRED)
include_directories( ${GLOG_INCLUDE_DIRS} )

#
# [Mesos] We need mesos
#
find_package(Mesos REQUIRED)
include_directories( ${Mesos_INCLUDE_DIR} )
message(STATUS "Mesos compiled with protobuf version ${Mesos_PROTOBUF_MAJOR}.${Mesos_PROTOBUF_MINOR}")

# Validate that the protobuf version used is accepted
string(REGEX MATCHALL "[0-9]+" PROTOBUF_VERSION_PARTS "${PROTOBUF_VERSION}")
list(GET PROTOBUF_VERSION_PARTS 0 PROTOBUF_VERSION_MAJOR)
list(GET PROTOBUF_VERSION_PARTS 1 PROTOBUF_VERSION_MINOR)
if (NOT "${PROTOBUF_VERSION_MAJOR}" STREQUAL "${Mesos_PROTOBUF_MAJOR}" OR NOT "${Mesos_PROTOBUF_MINOR}" STREQUAL "${PROTOBUF_VERSION_MINOR}")
  message(FATAL_ERROR
      "Mesos is compiled with protobuf version ${Mesos_PROTOBUF_MAJOR}.${Mesos_PROTOBUF_MINOR} "
      "but you have selected v${PROTOBUF_VERSION}. Please use the -DPROTOBUF_VERSION= option to select "
      "a more appropriate version from https://github.com/google/protobuf/releases ")
endif()

#
# [Protobuf] We are using a specific protobuf version that ships with the project
#            since mesos is shipped with a specific version on mind.
#
set( EXTERN_PROTOBUF "extern/protobuf" )
add_subdirectory( ${EXTERN_PROTOBUF} ${CMAKE_BINARY_DIR}/${EXTERN_PROTOBUF} )
include_directories( ${PROTOBUF_INCLUDE_DIRS} )
message( STATUS "Using locally-compiled protobuf library v${PROTOBUF_VERSION}" )

# Collect project libraries
set(
  PROJECT_LIBRARIES
  ${Mesos_LIBRARY}
)

#############################################################
# ADDITIONAL BUILD CONFIGURATION
#############################################################

# Enable C++11
include( CheckCXXCompilerFlag )
check_cxx_compiler_flag( "-std=c++11"   COMPILER_SUPPORTS_CXX11 )
check_cxx_compiler_flag( "-std=c++0x"   COMPILER_SUPPORTS_CXX0X )
if( COMPILER_SUPPORTS_CXX11 )
    if( CMAKE_COMPILER_IS_GNUCXX )
        set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11" )
    else()
        set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11" )
    endif()
elseif( COMPILER_SUPPORTS_CXX0X)
    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x" )
else()
    # MSVC, On by default (if available)
endif()

#############################################################
# TARGET BUILD
#############################################################

add_executable( ${PROJECT_NAME} src/main.cpp )
target_link_libraries( ${PROJECT_NAME} ${PROJECT_LIBRARIES} )
add_dependencies( ${PROJECT_NAME} protobuf )
