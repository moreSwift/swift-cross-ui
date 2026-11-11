#!/bin/sh

cd "$(dirname "$0")"/../

# `swift test` builds all targets in the package (even those not depended upon
# by any test targets), which leads to `swift test` on its own being broken
# for SwiftCrossUI
swift test --test-product swift-cross-uiPackageTests $@
