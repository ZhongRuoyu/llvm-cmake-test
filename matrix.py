#!/usr/bin/env python3

import datetime
import json
import os
import re
import requests
from typing import Optional

LLVM_VERSION = os.getenv("LLVM_VERSION").split(",")
NINJA = list(map(lambda s: bool(json.loads(s)), os.getenv("NINJA").split(",")))
CMAKE_MAJOR_MINOR_VERSION = os.getenv("CMAKE_MAJOR_MINOR_VERSION")
CMAKE_VERSION = os.getenv("CMAKE_VERSION").split(",") if os.getenv("CMAKE_VERSION") else None
BEGIN_DATE = datetime.datetime.strptime(os.getenv("BEGIN_DATE"), "%Y-%m-%d")
END_DATE = datetime.datetime.strptime(os.getenv("END_DATE"), "%Y-%m-%d")
INTERVAL = datetime.timedelta(days=int(os.getenv("INTERVAL")))


def cmake_nightly_files() -> list[str]:
  if getattr(cmake_nightly_files, "files", None) is None:
    response = requests.request("GET", "https://cmake.org/files/dev/?F=0").text
    pattern = re.compile(
        r"cmake-\d+(?:\.\d+)*-g[0-9a-f]+-linux-x86_64\.tar\.gz")
    cmake_nightly_files.files = re.findall(pattern, response)
  return cmake_nightly_files.files


def get_nightly_filename(date: datetime.datetime) -> Optional[str]:
  # pylint: disable=redefined-outer-name
  major, minor = map(int, CMAKE_MAJOR_MINOR_VERSION.split("."))
  major_minor_version_before = f"{major}.{minor - 1}"
  for version in [CMAKE_MAJOR_MINOR_VERSION, major_minor_version_before]:
    major_minor = re.escape(version)
    date_fmt = re.escape(date.strftime("%Y%m%d"))
    pattern = re.compile(
        fr"cmake-{major_minor}\.{date_fmt}-g[0-9a-f]+-linux-x86_64\.tar\.gz")
    for file in cmake_nightly_files():
      if re.match(pattern, file):
        return file
  return None


matrix = {}
matrix["llvm-version"] = LLVM_VERSION
matrix["ninja"] = NINJA
if CMAKE_VERSION:
  matrix["cmake-version"] = CMAKE_VERSION
else:
  cmake_filename = []
  date = BEGIN_DATE
  while date <= END_DATE:
    nightly_filename = get_nightly_filename(date)
    if nightly_filename:
      cmake_filename.append(nightly_filename)
    date += INTERVAL
  matrix["cmake-filename"] = cmake_filename
print(json.dumps(matrix))

# pylint: disable=unspecified-encoding
with open(os.getenv("GITHUB_OUTPUT", "/dev/stdout"), "a") as f:
  print(f"matrix={json.dumps(matrix)}", file=f)
