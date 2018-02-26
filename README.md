# mesos-dev-template

> A template for creating projects that interface with mesos

This project contains everything you need for starting developing anything that interface with mesos (executor, scheduler, module, etc.)

It consists of the required cmake scripts for:

* Locating mesos
* Locating Glog (required by mesos)
* Downloading custom protobuf version (for linking against specific mesos versions)

## Building

To build your project simply do:

```
mkdir build
cmake ..
make
```

### Targeting mesos versions

Be aware that mesos is released with the compiled protobuf headers included. This means you need the appropriate runtime version for protobuf in your development environment.

You can select any protobuf version to be included in your project using the `PROTOBUF_VERSION` parameter:

```
cmake -DPROTOBUF_VERSION=3.1.1 ..
```

If the version you have selected is not compatible with the version found in the `mesos.pb.h` file you will get a warning like this:

```
-- Mesos compiled with protobuf version 3.3
CMake Error at CMakeLists.txt:41 (message):
  Mesos is compiled with protobuf version 3.3 but you have selected v3.5.1.1.
  Please use the -DPROTOBUF_VERSION= option to select a more appropriate
  version from https://github.com/google/protobuf/releases
```
