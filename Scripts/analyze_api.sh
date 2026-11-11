#!/bin/bash

cd "$(dirname "$0")"/../APITool

swift run -c release APITool analyze --scui-checkout ..
