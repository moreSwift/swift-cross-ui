import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Pickers {
    public var supportedPickerStyles: [BackendPickerStyle] {
        [.menu, .segmented, .radioGroup]
    }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        switch style {
            case .menu:
                return NSPopUpButton()
            case .segmented:
                return NSSegmentedControl()
            case .radioGroup:
                return RadioGroup()
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
        if let picker = picker as? NSPopUpButton {
            picker.isEnabled = environment.isEnabled

            let menu = picker.menu!

            for (item, option) in zip(menu.items, options) {
                item.attributedTitle = Self.attributedString(for: option, in: environment)
            }

            if menu.numberOfItems < options.count {
                for i in menu.numberOfItems..<options.count {
                    let item = NSMenuItem()
                    item.attributedTitle = Self.attributedString(for: options[i], in: environment)
                    menu.addItem(item)
                }
            } else {
                for i in (options.count..<menu.numberOfItems).reversed() {
                    menu.removeItem(at: i)
                }
            }

            picker.onAction = { picker in
                let picker = picker as! NSPopUpButton
                onChange(picker.indexOfSelectedItem)
            }
            picker.bezelStyle = .regularSquare
        } else if let picker = picker as? NSSegmentedControl {
            picker.isEnabled = environment.isEnabled
            picker.segmentCount = options.count
            for (i, option) in options.enumerated() {
                picker.setLabel(option, forSegment: i)
            }
            picker.onAction = { picker in
                let picker = picker as! NSSegmentedControl
                let selectedIndex = picker.selectedSegment
                onChange(selectedIndex == -1 ? nil : selectedIndex)
            }
        } else if let picker = picker as? RadioGroup {
            picker.update(options: options, environment: environment)
            picker.onChange = onChange
        }
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        if let picker = picker as? NSPopUpButton {
            if let index = selectedOption {
                picker.selectItem(at: index)
            } else {
                picker.select(nil)
            }
        } else if let picker = picker as? NSSegmentedControl {
            picker.selectedSegment = selectedOption ?? -1
        } else if let picker = picker as? RadioGroup {
            picker.setSelectedIndex(to: selectedOption)
        }
    }
}
