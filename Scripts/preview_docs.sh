#!/bin/bash

set -e
cd "$(dirname "$0")"

# This script previews SwiftCrossUI's documentation locally. Changes to
# Sources/SwiftCrossUI/SwiftCrossUI.docc should be refected live, but
# changes to source documentation require running the script again.
#
# To skip symbol graph generation (when you don't care about symbol
# links or source documentation) set SKIP_SYMBOL_GRAPHS=1.

./ensure_docc.sh

cd ..

if [ -z "$DOCC_HTML_DIR"]; then
    docc_path=""
    if command -v xcrun >/dev/null 2>&1; then
        # If on macOS, use xcrun to find the real docc executable
        docc_path="$(xcrun --find docc)"
    else
        # If not on macOS use 'command' to discover the path of docc
        docc_path="$(command -v docc)"

        # If docc is a symlink to swiftly, then use swiftly to find the real
        # docc executable
        docc_path="$(realpath "$docc_path")"
        docc_filename="$(basename "$docc_path")"
        if [[ "$docc_filename" == "swiftly" ]]; then
            swiftly_path="$docc_path"
            docc_path="$(exec "$swiftly_path" run which docc)"
        fi
    fi

    # The DocC HTML template should always be at the same location relative to
    # the DocC executable as far as I know
    export DOCC_HTML_DIR="$(dirname -- $docc_path)/../share/docc/render"
fi

if [[ "$SKIP_SYMBOL_GRAPHS" != "1" ]]; then
    # Generate symbol graphs so that symbol links work
    mkdir -p .build/symbol-graphs
    swift build --target SwiftCrossUI \
        -Xswiftc -emit-symbol-graph \
        -Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs
fi

./Tools/docc preview ./Sources/SwiftCrossUI/SwiftCrossUI.docc \
    --additional-symbol-graph-dir .build/symbol-graphs \
    --transform-for-static-hosting \
    --source-service github \
    --source-service-base-url https://github.com/moreSwift/swift-cross-ui/blob/main \
    --checkout-path .
