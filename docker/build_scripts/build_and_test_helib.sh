#!/bin/bash

# Default arguments
repo=https://github.com/IBM-HElib/HElib.git
branch=master
package=true
all=false
tests=false
examples=false
utils=false
gbench=false

# Function for printing usage info.
function printUsage {
  echo "Usage: CMD [-h] [-r <repo>] [-b <branch>] [-p] [-l] [-t] [-e] [-u] [-g] [-a]" 
  echo "    -h             Displays this help message."
  echo "    -r <repo>      HElib repo to clone (Default = https://github.com/IBM-HElib/HElib.git)."
  echo "    -b <branch>    Branch of HElib to checkout (Default = master)."
  echo "    -p             Flag to indicate a package build (This is the default build type)."
  echo "    -l             Flag to indicate a library build."
  echo "    -t             Run the HElib Google tests."
  echo "    -e             Build and test the HElib examples directory."
  echo "    -u             Build and test the HElib utils directory."
  echo "    -g             Build the HElib Google benchmark directory."
  echo "    -a             Build and test all of the above."
}

while getopts ":hr:b:plteuga" opt; do
  case ${opt} in
    h ) printUsage
        exit 0
        ;;
    r ) repo=$OPTARG
        ;;
    b ) branch=$OPTARG
        ;;
    p ) package=true
        ;;
    l ) package=false
        ;;
    t ) tests=true 
        all=false
        ;;
    e ) examples=true
        all=false
        ;;
    u ) utils=true
        all=false
        ;;
    g ) gbench=true
        all=false
        ;;
    a ) all=true
        ;;
    : ) echo "Invalid option: $OPTARG requires an argument." 1>&2
        printUsage
        exit 1
        ;;
    \?) echo "Invalid option: $OPTARG" 1>&2
        printUsage
        exit 1
        ;;
  esac
done


# Clone and build HElib
cd
git clone ${repo} # Default = https://github.com/IBM-HElib/HElib.git
cd HElib
git checkout ${branch} # Default = master
mkdir build
cd build
cmake -DPACKAGE_BUILD=${package} -DBUILD_SHARED=ON -DCMAKE_INSTALL_PREFIX="$HOME/helib_build_install" -DENABLE_TEST=${tests} ..
make -j4 VERBOSE=1
make install

# Run the google tests
if [[ ${all} || ${tests} ]]; then
  ctest -j4 --output-on-failure --no-compress-output --test-output-size-passed 32768 --test-output-size-failed 262144 -T Test
fi

# Build and test the examples
if [[ ${all} || ${examples} ]]; then
  cd ../examples
  mkdir build
  cd build
  cmake -Dhelib_DIR=$HOME/helib_build_install/share/cmake/helib/ ..
  make -j4 VERBOSE=1
  cd ../tests
  bats -j 4 .
fi

# Build and test the utilities
if [[ ${all} || ${utils} ]]; then
  cd ../../utils
  mkdir build
  cd build
  cmake -Dhelib_DIR=$HOME/helib_build_install/share/cmake/helib/ ..
  make -j4 VERBOSE=1
  cd ../tests
  bats -j 4 .
fi

# Build benchmarks
if [[ ${all} || ${gbench} ]]; then
  cd ../../benchmarks
  mkdir build
  cd build
  cmake -Dhelib_DIR=$HOME/helib_build_install/share/cmake/helib/ ..
  make -j4 VERBOSE=1
fi
