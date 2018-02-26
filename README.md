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

To check the version of the protobuf headers shipped with your mesos installation use this command:

```
~$ cat /usr/include/mesos/mesos.pb.h | grep '#if GOOGLE_PROTOBUF_VERSION' | awk '{ print $4}'
3005000
```

