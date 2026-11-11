import SwiftCrossUI
import Foundation

struct V1: View {
    @Binding var toggleState: Bool
    @Binding var date: Date
    @Binding var option: String?

    var body: some View {
        VStack {
            Toggle("Toggle", isOn: $toggleState)
            DatePicker("DatePicker", selection: $date)
            Picker(of: EnvironmentHeavyView.pickerOptions, selection: $option)
            Button("Click me!") {}
        }
        .foregroundColor(.black)
        .toggleStyle(.button)
        .datePickerStyle(.automatic)
        .pickerStyle(.menu)
        .buttonStyle(.bordered)
    }
}

struct H1: View {
    @Binding var toggleState: Bool
    @Binding var date: Date
    @Binding var option: String?

    var body: some View {
        HStack {
            Toggle("Toggle", isOn: $toggleState)
            DatePicker("DatePicker", selection: $date)
            Picker(of: EnvironmentHeavyView.pickerOptions, selection: $option)
            Button("Click me!") {}

            V1(toggleState: _toggleState, date: _date, option: _option)
            V1(toggleState: _toggleState, date: _date, option: _option)
            V1(toggleState: _toggleState, date: _date, option: _option)
        }
        .foregroundColor(.blue)
        .toggleStyle(.checkbox)
        .datePickerStyle(.compact)
        .pickerStyle(.radioGroup)
        .buttonStyle(.borderless)
    }
}

struct V2: View {
    @Binding var toggleState: Bool
    @Binding var date: Date
    @Binding var option: String?

    var body: some View {
        VStack {
            Toggle("Toggle", isOn: $toggleState)
            DatePicker("DatePicker", selection: $date)
            Picker(of: EnvironmentHeavyView.pickerOptions, selection: $option)
            Button("Click me!") {}

            H1(toggleState: _toggleState, date: _date, option: _option)
            H1(toggleState: _toggleState, date: _date, option: _option)
            H1(toggleState: _toggleState, date: _date, option: _option)
        }
        .foregroundColor(.brown)
        .toggleStyle(.switch)
        .datePickerStyle(.graphical)
        .pickerStyle(.segmented)
        .buttonStyle(.plain)
    }
}

struct H2: View {
    @Binding var toggleState: Bool
    @Binding var date: Date
    @Binding var option: String?

    var body: some View {
        VStack {
            Toggle("Toggle", isOn: $toggleState)
            DatePicker("DatePicker", selection: $date)
            Picker(of: EnvironmentHeavyView.pickerOptions, selection: $option)
            Button("Click me!") {}

            V2(toggleState: _toggleState, date: _date, option: _option)
            V2(toggleState: _toggleState, date: _date, option: _option)
            V2(toggleState: _toggleState, date: _date, option: _option)
        }
        .foregroundColor(.cyan)
        .toggleStyle(.button)
        .datePickerStyle(.automatic)
        .pickerStyle(.wheel)
        .buttonStyle(.bordered)
    }
}

struct V3: View {
    @Binding var toggleState: Bool
    @Binding var date: Date
    @Binding var option: String?

    var body: some View {
        VStack {
            Toggle("Toggle", isOn: $toggleState)
            DatePicker("DatePicker", selection: $date)
            Picker(of: EnvironmentHeavyView.pickerOptions, selection: $option)
            Button("Click me!") {}

            H2(toggleState: _toggleState, date: _date, option: _option)
            H2(toggleState: _toggleState, date: _date, option: _option)
            H2(toggleState: _toggleState, date: _date, option: _option)
        }
        .foregroundColor(.gray)
        .toggleStyle(.checkbox)
        .datePickerStyle(.compact)
        .pickerStyle(.menu)
        .buttonStyle(.borderless)
    }
}

struct EnvironmentHeavyView: TestCaseView {
    @State var toggleState = true
    @State var date = Date()
    @State var option: String?

    static let pickerOptions = ["foo", "bar", "baz", "qux"]

    var body: some View {
        HStack {
            Toggle("Toggle", isOn: $toggleState)
            DatePicker("DatePicker", selection: $date)
            Picker(of: EnvironmentHeavyView.pickerOptions, selection: $option)
            Button("Click me!") {}

            V3(toggleState: $toggleState, date: $date, option: $option)
            V3(toggleState: $toggleState, date: $date, option: $option)
            V3(toggleState: $toggleState, date: $date, option: $option)
        }
        .foregroundColor(.green)
        .toggleStyle(.switch)
        .datePickerStyle(.graphical)
        .pickerStyle(.radioGroup)
        .buttonStyle(.plain)
    }
}
