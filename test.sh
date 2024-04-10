#!/bin/bash

set -euo pipefail

group() {
  # stdout and stderr synchronisation seems to be imperfect in GitHub Actions.
  echo "::group::$*"
  sleep 3
  set -x
  "$@" || true
  set +x
  sleep 3
  echo "::endgroup::"
}

group ls /opt/llvm/bin
group ls /opt/llvm/include
group ls /opt/llvm/include/c++/v1
group ls /opt/llvm/lib
