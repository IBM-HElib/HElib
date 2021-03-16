# Build and Tests

## Introduction
This directory provides dockerfiles and a script for building and testing
HElib. This can be used to test various versions and configurations of HElib in
self-contained docker containers.

## What is provided
Currently provided:
- Dockerfiles:
    - Ubuntu 20.04
    - Fedora 33
    - CentOS 8
- Test script for cloning, build and testing HElib and all subprojects

The Dockerfiles provided contain recipes for installing all prerequisites for
HElib as well as the test script found in `build_scripts`.

## Running the build script

The script `build_and_test_helib.sh` has a help method which prints the usage
to the console and can be run with
```
./build_and_test_helib.sh -h
```

By default, the script clones
[IBM-HElib/HElib](https://github.com/IBM-HElib/HElib), performs a package build
and only compiles and installs the library. To run the tests or use a lib build
extra flags must be passed to the script.

**NOTE:** HElib is always cloned in the user's home directory.

It is possible to tell the script what repository to clone using the `-r
<repo>` option, where `<repo>` is the HTTPS link to perform the clone from.
Additionally, one can select a specific branch to build and test using the `-b
<branch>` option.

## Running the docker containers

1. Using the dockerfiles provided, first build the images, for example from the
   `HElib/docker/build_and_test` directory
   ```
   docker build -t he-ready-ubuntu:20.04 -f Dockerfile.UBUNTU .
   ```
   will build the Ubuntu 20.04 image and tag it with the name
   `he-ready-ubuntu:20.04`.
   
2. Once the images are built you can run the containers. The containers will by
   default run the bash script described above. For example
   ```
   docker run --name default_ubuntu_test he-ready-ubuntu:20.04
   ```
   will spin a container called `default_ubuntu_test` and run internally
   `./root/build_and_test_helib.sh -a`. This will clone `IBM-HElib/HElib`,
   perform a package build and install, run the Google tests, and then build
   and run the tests for all subprojects.

   **OPTIONAL:** It is possible to override the default build of each docker
   container by specifying your own inputs during the run command, for example
   ```
   docker run --name my_ubuntu_test he-ready-ubuntu:20.04 ./root/build_and_test_helib.sh -r https://github.com/homenc/HElib.git -lt
   ```
   This command will run an Ubuntu 20.04 container called `my_ubuntu_test`
   with the following custom options:
   - the `-r` flag will instead clone [homenc/HElib](https://github.com/homenc/HElib), defaulting to the master branch
   - the `-l` flag tells the script to build HElib using the library build
   - the `-t` flag tells the script to only run the HElib Google tests and nothing else

   To see the additional options available look at the usage info for the script.
