#!/usr/bin/env sh
set -euo pipefail

windows_path() {
    case "$1" in
        /cygdrive/?/*)
            drive="$(printf '%s' "$1" | cut -c 11 | tr '[:lower:]' '[:upper:]')"
            rest="$(printf '%s' "$1" | cut -c 13-)"
            printf '%s:/%s\n' "$drive" "$rest"
            ;;
        \\cygdrive\\?\\*)
            drive="$(printf '%s' "$1" | cut -c 12 | tr '[:lower:]' '[:upper:]')"
            rest="$(printf '%s' "$1" | cut -c 14- | tr '\\' '/')"
            printf '%s:/%s\n' "$drive" "$rest"
            ;;
        *)
            printf '%s\n' "$1"
            ;;
    esac
}

script_dir="$(windows_path "$(cd "$(dirname "$0")" && pwd)")"
repo_root="$(windows_path "$(cd "$script_dir/.." && pwd)")"
output_dir="$(windows_path "$script_dir/output")"
compile_work_dir="$(windows_path "${COMPILE_WORK_DIR:-$script_dir/.compile-work}")"
package_dir="$compile_work_dir/TestApps"
sources_root="$package_dir/Sources"

swift_bin="${SWIFT_BIN:-swift}"
needs_image_formats=0

mkdir -p "$output_dir" "$sources_root"

compile_app() {
    app_file="$1"
    source_path="$script_dir/$app_file"

    if [ ! -f "$source_path" ]; then
        echo "Missing source file: $source_path" >&2
        exit 1
    fi

    app_name="${app_file%.swift}"
    target_dir="$sources_root/$app_name"
    mkdir -p "$target_dir"
    cp "$source_path" "$target_dir/main.swift"

    if grep -q '^import ImageFormats' "$source_path"; then
        needs_image_formats=1
    fi
}

if [ "$#" -gt 0 ]; then
    app_names=""
    for app in "$@"; do
        case "$app" in
            *.swift) app_file="$app" ;;
            *) app_file="$app.swift" ;;
        esac

        compile_app "$app_file"
        app_name="${app_file%.swift}"
        app_names="$app_names $app_name"
    done
else
    app_names=""
    found_any=0
    for source_path in "$script_dir"/P*.swift; do
        if [ ! -f "$source_path" ]; then
            continue
        fi

        found_any=1
        app_file="$(basename "$source_path")"
        compile_app "$app_file"
        app_name="${app_file%.swift}"
        app_names="$app_names $app_name"
    done

    if [ "$found_any" -eq 0 ]; then
        echo "No P*.swift files found in $script_dir" >&2
        exit 1
    fi
fi

targets=""
for app_name in $app_names; do
    targets="$targets
        .executableTarget(
            name: \"$app_name\",
            dependencies: testAppDependencies
        ),"
done

image_formats_product=""
image_formats_package=""
if [ "$needs_image_formats" -eq 1 ]; then
    image_formats_product='
    .product(name: "ImageFormats", package: "swift-image-formats"),'
    image_formats_package='
        .package(
            url: "https://github.com/stackotter/swift-image-formats",
            .upToNextMinor(from: "0.5.0")
        ),'
fi

cat > "$package_dir/Package.swift" <<EOF_PACKAGE
// swift-tools-version:5.10

import PackageDescription

let testAppDependencies: [Target.Dependency] = [
    .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
    .product(name: "DefaultBackend", package: "swift-cross-ui"),
    .product(name: "WinUIBackend", package: "swift-cross-ui", condition: .when(platforms: [.windows])),
    $image_formats_product
    .product(name: "WinUI", package: "swift-winui", condition: .when(platforms: [.windows])),
    .product(name: "UWP", package: "swift-winui", condition: .when(platforms: [.windows])),
]

let package = Package(
    name: "TestApps",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .macCatalyst(.v13), .visionOS(.v1)],
    dependencies: [
        .package(path: "$repo_root"),
        $image_formats_package
        .package(
            url: "https://github.com/moreSwift/swift-winui",
            .upToNextMinor(from: "0.2.1")
        ),
    ],
    targets: [$targets
    ]
)
EOF_PACKAGE

for app_name in $app_names; do
    echo "==> Compiling $app_name"
    "$swift_bin" build \
        --package-path "$package_dir" \
        --product "$app_name" \
        -c debug

    exe_path=""
    triple_dir="$(find "$package_dir/.build" -maxdepth 1 -type d -name '*-*-*' | head -n 1 || true)"
    if [ -n "$triple_dir" ] && [ -f "$triple_dir/debug/$app_name.exe" ]; then
        exe_path="$triple_dir/debug/$app_name.exe"
        output_path="$output_dir/$app_name.exe"
    elif [ -n "$triple_dir" ] && [ -f "$triple_dir/debug/$app_name" ]; then
        exe_path="$triple_dir/debug/$app_name"
        output_path="$output_dir/$app_name"
    elif [ -f "$package_dir/.build/debug/$app_name.exe" ]; then
        exe_path="$package_dir/.build/debug/$app_name.exe"
        output_path="$output_dir/$app_name.exe"
    elif [ -f "$package_dir/.build/debug/$app_name" ]; then
        exe_path="$package_dir/.build/debug/$app_name"
        output_path="$output_dir/$app_name"
    else
        echo "Build succeeded but executable was not found for $app_name" >&2
        exit 1
    fi

    rm -f "$output_path"
    cp "$exe_path" "$output_path"
    echo "    -> $output_path"

    for resource_dir in \
        "$triple_dir/debug/swift-winui_CWinAppSDK.resources" \
        "$triple_dir/debug/swift-winui_CWinAppSDK.bundle" \
        "$package_dir/.build/debug/swift-winui_CWinAppSDK.resources" \
        "$package_dir/.build/debug/swift-winui_CWinAppSDK.bundle"
    do
        if [ -d "$resource_dir" ]; then
            resource_name="$(basename "$resource_dir")"
            rm -rf "$output_dir/$resource_name"
            cp -R "$resource_dir" "$output_dir/$resource_name"
            echo "    -> $output_dir/$resource_name"
            break
        fi
    done
done

echo "Done. Output directory: $output_dir"
