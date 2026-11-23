#!/bin/bash

cd "$(dirname "$0")"/../

# Generate Gtk3 wrapper
swift run --enable-experimental-prebuilts GtkCodeGen Sources/GtkCodeGen/GirFiles/Gtk-3.0.gir Sources/Gtk3/Generated CGtk3
./Scripts/format.sh Sources/Gtk3/Generated
