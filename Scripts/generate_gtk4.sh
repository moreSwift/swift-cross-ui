#!/bin/bash

cd "$(dirname "$0")"/../

# Generate Gtk4 wrapper
swift run --enable-experimental-prebuilts GtkCodeGen Sources/GtkCodeGen/GirFiles/Gtk-4.0.gir Sources/Gtk/Generated CGtk
./Scripts/format.sh Sources/Gtk/Generated
