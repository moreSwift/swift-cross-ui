#!/bin/bash

cd "$(dirname "$0")"/../

if [ -z "$1" ]; then
  swiftformat .
else
  swiftformat $1
fi

if which java &>/dev/null; then
  ./Scripts/ensure_ktfmt.sh

  java -jar Tools/ktfmt.jar --kotlinlang-style --quiet Sources/AndroidBackend/Kotlin/
else
  echo 'Skipping ktfmt, as Java was not found. To format Kotlin files, install Java 17.' >&2
fi
