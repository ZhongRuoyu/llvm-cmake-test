#!/bin/bash

set -euxo pipefail

mkdir -p /opt/cmake
curl -fL "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" |
  tar -C /opt/cmake -xz --strip-components=1
export PATH="/opt/cmake/bin:$PATH"
cmake --version

mkdir -p llvm-project
curl -fL "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/llvm-project-$LLVM_VERSION.src.tar.xz" |
  tar -C llvm-project -xJ --strip-components=1

cmake -S llvm-project/llvm -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
  -DLLVM_ENABLE_RUNTIMES="libcxx;openmp" \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON
cmake --build build -j "$(nproc)"
cmake --build build --target install

tar -C /opt -czf "llvm-$LLVM_VERSION-cmake-$CMAKE_VERSION.tar.gz" llvm
tar -czf "llvm-$LLVM_VERSION-cmake-$CMAKE_VERSION-build.tar.gz" build

set +e

ls -v /opt/llvm/bin
ls -v /opt/llvm/include
ls -v /opt/llvm/include/c++/v1
ls -v /opt/llvm/lib