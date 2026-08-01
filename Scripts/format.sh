#!/bin/bash

cd "$(dirname "$0")"/../

# Minimum SwiftFormat version required by the rules enabled in .swiftformat.
# simplifyGenericConstraints (the newest rule in --rules) was added in 0.59.0;
# older SwiftFormat versions reject it with "Unknown rule: simplifyGenericConstraints".
MIN_SWIFTFORMAT_VERSION="0.59.0"

if ! which swiftformat &>/dev/null; then
  echo "swiftformat not found. Install it with 'brew install swiftformat' (or see https://github.com/nicklockwood/SwiftFormat/releases)." >&2
  exit 1
fi

installed_version="$(swiftformat --version | tr -dc '0-9.')"

version_ge() {
  # Compares dot-separated version numbers component-by-component without
  # relying on GNU sort -V, which macOS's built-in sort does not support.
  local IFS=.
  local -a v1=($1)
  local -a v2=($2)
  local i
  for ((i = 0; i < 3; i++)); do
    local a="${v1[i]:-0}"
    local b="${v2[i]:-0}"
    if ((10#$a > 10#$b)); then
      return 0
    elif ((10#$a < 10#$b)); then
      return 1
    fi
  done
  return 0
}

if ! version_ge "$installed_version" "$MIN_SWIFTFORMAT_VERSION"; then
  echo "SwiftFormat $installed_version is too old; this repo's .swiftformat rules require >= $MIN_SWIFTFORMAT_VERSION." >&2
  echo "Upgrade with 'brew upgrade swiftformat' (or 'mint install nicklockwood/SwiftFormat'), or download a release from https://github.com/nicklockwood/SwiftFormat/releases." >&2
  exit 1
fi

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
