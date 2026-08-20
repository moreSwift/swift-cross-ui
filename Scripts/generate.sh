#!/bin/bash

cd "$(dirname "$0")"

./generate_gyb.sh

./generate_gtk.sh

./generate_porting_kit.sh
