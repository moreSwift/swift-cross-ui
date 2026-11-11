## APITool

This tool helps with the analysis and management of SwiftCrossUI's public API surface. That includes diffing SwiftCrossUI's API surface against SwiftUI's API surface, and generating the stubs that live at `../Sources/_SwiftCrossUIPortingKit/Generated` which fill in missing SwiftUI APIs with the aim of making porting from SwiftUI to SwiftCrossUI easier.

> [!IMPORTANT]
> APITool only supports running on a macOS host, because it requires access to the SwiftUI and SwiftUICore swiftinterface files which ship with Xcode.

### Diffing SwiftCrossUI and SwiftUI

SwiftCrossUI has a convenient script at `../Scripts/analyze_api.sh` for diffing SwiftCrossUI and SwiftUI, but in case you want to do it manually, here's the command:

```sh
# Diff SwiftCrossUI and SwiftUI. If you want to use a developer directory
# different to the one reported by 'xcode-select --print-path', then you
# specify one using the '--developer-dir' CLI option
swift run -c release APITool analyze --scui-checkout ..
```

### Regenerating SwiftCrossUIPortingKit's generated files

SwiftCrossUI has a convenient script at `../Scripts/generate_porting_kit.sh` for regenerating the porting kit's generated files, but in case you want to do it manually, here's the command:

```sh
# Regenerate the porting kit's generated files
swift run -c release APITool generate --scui-checkout .. \
  ../Sources/_SwiftCrossUIPortingKit/Generated
```

Unlike `../Scripts/generate_porting_kit.sh`, this won't format the generated files. Run `../Scripts/format.sh ../Sources/_SwiftCrossUIPortingKit/Generated` to format the generated files.

### Generating SwiftCrossUI's swiftinterface file manually

APITool automatically generates a swiftinterface file for SwiftCrossUI whenever one is needed, but if you want to do it manually for whatever reason, this is the command that APITool runs:

```sh
swift build --target SwiftCrossUI -Xswiftc -emit-module-interface
```

The resulting swiftinterface file will be at
`.build/debug/SwiftCrossUI.build/SwiftCrossUI.swiftinterface`
