#!/bin/bash

set -euo pipefail

group() {
  echo "::group::$*"
  set -x
  "$@" || true
  set +x
  # stdout and stderr synchronisation seems to be imperfect in GitHub Actions.
  sleep 3
  echo "::endgroup::"
}

group ls /opt/llvm/bin
group ls /opt/llvm/include
group ls /opt/llvm/include/c++/v1
group ls /opt/llvm/lib
