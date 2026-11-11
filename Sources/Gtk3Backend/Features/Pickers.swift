import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.Pickers {
    public var supportedPickerStyles: [BackendPickerStyle] { [] }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    public func setSelectedOption(
        ofPicker picker: Widget,
        to selectedOption: Int?
    ) {
        fatalError("\(Self.self): \(#function) not implemented")
    }

    // public func createPicker() -> Widget {
    //     return DropDown(strings: [])
    // }

    // public func updatePicker(
    //     _ picker: Widget,
    //     options: [String],
    //     environment: EnvironmentValues,
    //     onChange: @escaping (Int?) -> Void
    // ) {
    //     let picker = picker as! DropDown
    //     picker.sensitive = environment.isEnabled

    //     // Check whether the options need to be updated or not (avoiding unnecessary updates is
    //     // required to prevent an infinite loop caused by the onChange handler)
    //     var hasChanged = false
    //     for index in 0..<options.count {
    //         guard
    //             let item = gtk_string_list_get_string(picker.model, guint(index)),
    //             String(cString: item) == options[index]
    //         else {
    //             hasChanged = true
    //             break
    //         }
    //     }

    //     // picker.model could be longer than options
    //     if gtk_string_list_get_string(picker.model, guint(options.count)) != nil {
    //         hasChanged = true
    //     }

    //     // Apply the current text styles to the dropdown's labels
    //     var block = CSSBlock(forClass: picker.css.cssClass + " label")
    //     block.set(properties: Self.cssProperties(for: environment))
    //     picker.cssProvider.loadCss(from: block.stringRepresentation)

    //     guard hasChanged else {
    //         return
    //     }

    //     picker.model = gtk_string_list_new(
    //         UnsafePointer(
    //             options
    //                 .map({ UnsafePointer($0.unsafeUTF8Copy().baseAddress) })
    //                 .unsafeCopy()
    //                 .baseAddress
    //         )
    //     )

    //     picker.notifySelected = { picker in
    //         if picker.selected == GTK_INVALID_LIST_POSITION {
    //             onChange(nil)
    //         } else {
    //             onChange(picker.selected)
    //         }
    //     }
    // }

    // public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
    //     let picker = picker as! DropDown
    //     if selectedOption != picker.selected {
    //         picker.selected = selectedOption ?? Int(GTK_INVALID_LIST_POSITION)
    //     }
    // }
}
