# llvm-cmake-test

While building LLVM 17 and 18, it was discovered that LLVM runtimes could not be
installed.

Preliminary investigation suggested that this was likely a regression in CMake.
This repository was created to test the issue and search for the root cause.

The final search narrowed down to commit range
[`a99f5281...104dfe15`](https://gitlab.kitware.com/ci-forks/cmake/cmake/-/compare/a99f5281b6aaf3a6c384c6ffea21a643d9a14dd8...104dfe154ce6504a7b82dbc28f7798ee1aa2ce15)
and it was identified that the issue was introduced by commit
[`3f2a5971`](https://gitlab.kitware.com/cmake/cmake/-/commit/3f2a5971c02450e24bc8852a84dcd136fae5de18),
first released in CMake 3.29.0.

This issue was first reported at
[llvm/llvm-project#86744](https://github.com/llvm/llvm-project/issues/86744),
tracked at
[cmake/cmake#25883](https://gitlab.kitware.com/cmake/cmake/-/issues/25883),
and fixed by
[cmake/cmake!9416](https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9416).
