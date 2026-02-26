import SwiftCrossUI
import UIKit

protocol Picker: WidgetProtocol {
    func setOptions(to options: [String])
    func setChangeHandler(to onChange: @escaping (Int?) -> Void)
    func setSelectedOption(to index: Int?)
    func updateEnvironment(_ environment: EnvironmentValues)
}

@available(tvOS, unavailable)
final class UIPickerViewPicker: WrapperWidget<UIPickerView>, Picker, UIPickerViewDataSource,
    UIPickerViewDelegate
{
    private var options: [String] = []
    private var onSelect: ((Int?) -> Void)?

    init() {
        super.init(child: UIPickerView())

        child.dataSource = self
        child.delegate = self

        child.selectRow(0, inComponent: 0, animated: false)
    }

    func setOptions(to options: [String]) {
        self.options = options
        child.reloadComponent(0)
    }

    func setChangeHandler(to onChange: @escaping (Int?) -> Void) {
        onSelect = onChange
    }

    func setSelectedOption(to index: Int?) {
        child.selectRow(
            (index ?? -1) + 1,
            inComponent: 0,
            animated: false
        )
    }

    func updateEnvironment(_ environment: EnvironmentValues) {
        child.isUserInteractionEnabled = environment.isEnabled
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count + 1
    }

    // For some reason, if compiling for tvOS, the compiler complains if I even attempt
    // to define these methods.
    #if !os(tvOS)
        func pickerView(
            _: UIPickerView,
            titleForRow row: Int,
            forComponent _: Int
        ) -> String? {
            switch row {
                case 0:
                    ""
                case 1...options.count:
                    options[row - 1]
                default:
                    nil
            }
        }

        func pickerView(
            _: UIPickerView,
            didSelectRow row: Int,
            inComponent _: Int
        ) {
            onSelect?(row > 0 ? row - 1 : nil)
        }
    #endif
}

final class UITableViewPicker: WrapperWidget<UITableView>, Picker, UITableViewDelegate,
    UITableViewDataSource
{
    private static let reuseIdentifier =
        "__SwiftCrossUI_UIKitBackend_UITableViewPicker.reuseIdentifier"

    private var options: [String] = []
    private var onSelect: ((Int?) -> Void)?

    init() {
        super.init(child: UITableView(frame: .zero, style: .plain))

        child.delegate = self
        child.dataSource = self

        child.register(UITableViewCell.self, forCellReuseIdentifier: Self.reuseIdentifier)
    }

    func setOptions(to options: [String]) {
        self.options = options
        child.reloadData()
    }

    func setChangeHandler(to onChange: @escaping (Int?) -> Void) {
        onSelect = onChange
    }

    func setSelectedOption(to index: Int?) {
        if let index {
            child.selectRow(
                at: IndexPath(row: index, section: 0),
                animated: true,
                scrollPosition: .middle
            )
        } else {
            child.selectRow(at: nil, animated: false, scrollPosition: .none)
        }
    }

    func updateEnvironment(_ environment: EnvironmentValues) {
        child.isUserInteractionEnabled = environment.isEnabled
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Self.reuseIdentifier, for: indexPath)

        cell.textLabel!.text = options[indexPath.row]

        return cell
    }

    func tableView(
        _: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        onSelect?(indexPath.row)
    }
}

final class UISegmentedControlPicker: WrapperWidget<UISegmentedControl>, Picker {
    private var options: [String] = []
    private var onSelect: ((Int?) -> Void)?

    init() {
        super.init(child: UISegmentedControl())

        child.addTarget(self, action: #selector(selectionChanged), for: .valueChanged)
    }

    func setOptions(to options: [String]) {
        self.options = options

        for i in 0..<min(options.count, child.numberOfSegments) {
            child.setTitle(options[i], forSegmentAt: i)
        }

        if options.count > child.numberOfSegments {
            for option in options[child.numberOfSegments...] {
                child.insertSegment(withTitle: option, at: child.numberOfSegments, animated: false)
            }
        } else {
            for i in (options.count..<child.numberOfSegments).reversed() {
                child.removeSegment(at: i, animated: false)
            }
        }
    }

    func setChangeHandler(to onChange: @escaping (Int?) -> Void) {
        onSelect = onChange
    }

    func setSelectedOption(to index: Int?) {
        child.selectedSegmentIndex = index ?? UISegmentedControl.noSegment
    }

    func updateEnvironment(_ environment: EnvironmentValues) {
        child.isEnabled = environment.isEnabled
    }

    @objc func selectionChanged() {
        let selectedIndex = child.selectedSegmentIndex
        onSelect?(selectedIndex == UISegmentedControl.noSegment ? nil : selectedIndex)
    }
}

@available(iOS 14, macCatalyst 14, tvOS 17, *)
final class UIButtonPicker: WrapperWidget<UIButton>, Picker {
    private var options: [String] = []
    private var onSelect: ((Int?) -> Void)?
    private var selectedIndex: Int?

    init() {
        super.init(child: UIButton())

        let imageName =
            if #available(iOS 26, macCatalyst 26, tvOS 26, visionOS 2, *) {
                "chevron.compact.up.chevron.compact.down"
            } else {
                "chevron.up.chevron.down"
            }
        let image = UIImage(systemName: imageName)

        child.setImage(image, for: .normal)
        child.imageEdgeInsets.left = 2

        // Render the chevrons to the right of the text (they render to the left by default)
        child.semanticContentAttribute = .forceRightToLeft

        child.showsMenuAsPrimaryAction = true
    }

    func setOptions(to options: [String]) {
        self.options = options
        updateMenu()
    }

    func setChangeHandler(to onChange: @escaping (Int?) -> Void) {
        onSelect = onChange
    }

    func setSelectedOption(to index: Int?) {
        selectedIndex = index
        updateMenu()
    }

    private func updateMenu() {
        child.menu = UIMenu(
            children: options.enumerated().map { offset, element in
                UIAction(title: element, state: offset == selectedIndex ? .on : .off) {
                    [unowned self] _ in

                    selectedIndex = offset
                    onSelect?(offset)
                    updateMenu()
                }
            }
        )
    }

    func updateEnvironment(_ environment: EnvironmentValues) {
        child.isEnabled = environment.isEnabled

        let color = environment.foregroundColor?.resolve(in: environment).uiColor ?? .link
        let title = selectedIndex.map { options[$0] } ?? ""

        #if os(tvOS)
            child.setTitle(title, for: .normal)
        #else
            child.setAttributedTitle(
                UIKitBackend.attributedString(
                    text: title,
                    environment: environment,
                    defaultForegroundColor: .link
                ),
                for: .normal
            )
        #endif

        // This was obtained experimentally by trying to visually match SwiftUI
        let chevronPointSizeScaleFactor = 0.8
        let resolvedFont = environment.resolvedFont
        let symbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: resolvedFont.pointSize * chevronPointSizeScaleFactor
        )
        child.setPreferredSymbolConfiguration(
            symbolConfiguration,
            forImageIn: .normal
        )

        child.tintColor = color

        if #available(iOS 16, macCatalyst 16, *) {
            child.preferredMenuElementOrder =
                switch environment.menuOrder {
                    case .automatic: .automatic
                    case .priority: .priority
                    case .fixed: .fixed
                }
        }
    }
}

extension UIKitBackend {
    public func createPicker(style: BackendPickerStyle) -> Widget {
        switch style {
            case .menu:
                if #available(iOS 14, macCatalyst 14, tvOS 17, *) {
                    UIButtonPicker()
                } else {
                    preconditionFailure("Current OS is too old to support menu buttons.")
                }
            case .radioGroup:
                preconditionFailure("radioGroup is unsupported in UIKitBackend")
            case .segmented:
                UISegmentedControlPicker()
            case .wheel:
                #if targetEnvironment(macCatalyst)
                    if #available(macCatalyst 14, *), UIDevice.current.userInterfaceIdiom == .mac {
                        UITableViewPicker()
                    } else {
                        UIPickerViewPicker()
                    }
                #elseif os(tvOS)
                    preconditionFailure("wheel is unsupported on tvOS")
                #else
                    UIPickerViewPicker()
                #endif
        }
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        let pickerWidget = picker as! any Picker
        pickerWidget.setChangeHandler(to: onChange)
        pickerWidget.setOptions(to: options)
        pickerWidget.updateEnvironment(environment)
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        let pickerWidget = picker as! any Picker
        pickerWidget.setSelectedOption(to: selectedOption)
    }
}
