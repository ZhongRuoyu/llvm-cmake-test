#!/bin/bash

set -euxo pipefail

group() {
  echo "::group::$*"
  "$@" || true
  # stdout and stderr synchronisation seems to be imperfect in GitHub Actions.
  sleep 3
  echo "::endgroup::"
}

group ls /opt/llvm/bin
group ls /opt/llvm/include
group ls /opt/llvm/include/c++/v1
group ls /opt/llvm/lib
