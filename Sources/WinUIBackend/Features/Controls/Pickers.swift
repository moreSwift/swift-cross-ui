@_spi(Backends) import SwiftCrossUI
import WinUI

extension WinUIBackend: BackendFeatures.Pickers {
    public var supportedPickerStyles: [BackendPickerStyle] { [.menu, .radioGroup] }
    public func createPicker(style: BackendPickerStyle) -> Widget {
        switch style {
            case .menu:
                let picker = CustomComboBox()
                picker.selectionChanged.addHandler { [weak picker] _, _ in
                    guard let picker else { return }
                    picker.onChangeSelection?(Int(picker.selectedIndex))
                }

                // When hovering over a picker, its foreground changes to black,
                // when the pointer exits the picker the foreground color remains
                // black instead of returning to its regular value. I've tried various
                // variations of the solution below and it seems like the only thing
                // that works is fully recreating the brush.
                picker.pointerExited.addHandler { [weak picker] _, _ in
                    guard let picker else { return }
                    let brush = SolidColorBrush()
                    brush.color = picker.actualForegroundColor
                    picker.foreground = brush
                }

                return picker
            case .radioGroup:
                let picker = CustomRadioButtons()

                picker.selectionChanged.addHandler { [weak picker] _, _ in
                    guard let picker else { return }
                    picker.onChangeSelection?(
                        picker.selectedIndex == -1 ? nil : Int(picker.selectedIndex)
                    )
                }

                return picker
            default:
                let message = "unsupported picker style \(style)"
                logger.critical("\(message)")
                fatalError(message)
        }
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        if let picker = picker as? CustomComboBox {
            picker.onChangeSelection = onChange
            environment.apply(to: picker)
            picker.actualForegroundColor =
                environment.suggestedForegroundColor.resolve(in: environment).uwpColor

            // Only update options past this point, otherwise the early return
            // will cause issues.
            guard options.count > 0 else {
                picker.options = []
                return
            }

            if options.count == picker.items.count {
                // for i in 0 ..< options.count {
                // TODO: Understands how to get ComboBox items in WinUI
                // if picker.items.getAt(UInt32(i)) as? String != options[i] {
                // picker.items.setAt(UInt32(1), options[i])
                // }
                // }
            } else if options.count > picker.items.count {
                if !picker.items.isEmpty {
                    for i in 0..<picker.items.count {
                        // if picker.items.getAt(UInt32(i)) as? String != options[i] {
                        picker.items.setAt(UInt32(i), options[i])
                        // }
                    }
                }
                for i in picker.items.count..<options.count {
                    picker.items.append(options[i])
                }
            } else {
                for i in 0..<options.count {
                    // if picker.items.getAt(UInt32(i)) as? String != options[i] {
                    picker.items.setAt(UInt32(i), options[i])
                    // }
                }
                for i in options.count..<picker.items.count {
                    picker.items.removeAt(UInt32(i))
                }
            }

            // TODO: Proper picker updating logic
            // TODO: Picker font handling

            picker.options = options
        } else if let picker = picker as? CustomRadioButtons {
            for i in 0..<min(picker.items.count, options.count) {
                (picker.items[i] as! TextBlock).text = options[i]
            }

            if picker.items.count > options.count {
                for i in (options.count..<picker.items.count).reversed() {
                    _ = picker.items.remove(at: i)
                }
            } else {
                for option in options[picker.items.count...] {
                    let block = TextBlock()
                    block.text = option
                    environment.apply(to: block)
                    picker.items.append(block)
                }
            }

            picker.onChangeSelection = onChange
        }
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        if let picker = picker as? ComboBox {
            picker.selectedIndex = Int32(selectedOption ?? 0)
        } else if let picker = picker as? RadioButtons {
            picker.selectedIndex = Int32(selectedOption ?? -1)
        }
    }
}
