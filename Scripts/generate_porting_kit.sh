#!/bin/bash

cd "$(dirname "$0")"/../APITool

swift run -c release APITool generate --scui-checkout .. \
  ../Sources/_SwiftCrossUIPortingKit/Generated
