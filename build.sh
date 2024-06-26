#!/bin/bash

set -euo pipefail

group() {
  # stdout and stderr synchronisation seems to be imperfect in GitHub Actions.
  echo "::group::$*"
  sleep 3
  set -x
  "$@"
  set +x
  sleep 3
  echo "::endgroup::"
}

setup_cmake() {
  mkdir -p /opt/cmake
  if [[ -n "$CMAKE_VERSION" ]]; then
    cmake_url="https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz"
  else
    cmake_url="https://cmake.org/files/dev/$CMAKE_FILENAME"
  fi
  curl -fL "$cmake_url" |
    tar -C /opt/cmake -xz --strip-components=1
  export PATH="/opt/cmake/bin:$PATH"
  cmake --version
}
group setup_cmake

setup_ninja() {
  if [[ -n "$USE_NINJA" ]]; then
    mkdir -p /opt/ninja/bin
    curl -fLO "https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip"
    unzip -d /opt/ninja/bin ninja-linux.zip
    export PATH="/opt/ninja/bin:$PATH"
    ninja --version
  fi
}
group setup_ninja

setup_llvm() {
  mkdir -p llvm-project
  curl -fL "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/llvm-project-$LLVM_VERSION.src.tar.xz" |
    tar -C llvm-project -xJ --strip-components=1
}
group setup_llvm

setup_build() {
  export CC="gcc-13"
  export CXX="g++-13"
  cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX="/opt/llvm"
    -DLLVM_ENABLE_PROJECTS="clang"
    -DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi;libunwind;openmp"
    -DLLVM_BUILD_LLVM_DYLIB=ON
    -DLLVM_INCLUDE_TESTS=OFF
    -DLLVM_LINK_LLVM_DYLIB=ON
  )
  if [[ -n "$USE_NINJA" ]]; then
    cmake_args=(-G Ninja "${cmake_args[@]}")
  fi
  cmake -S llvm-project/llvm -B build "${cmake_args[@]}"
}
group setup_build

group cmake --build build -j "$(nproc)"
group cmake --build build --target install

group tar -C /opt -czf "$BUILD_ID.tar.gz" llvm
group tar -czf "$BUILD_ID-build.tar.gz" build
