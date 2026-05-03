#!/bin/bash

cd "$(dirname "$0")"/../

if [ -z "$1" ]; then
  swiftformat .
else
  swiftformat $1
fi
