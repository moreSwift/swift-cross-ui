import WinUI

final class CustomRadioButtons: RadioButtons {
    var onChangeSelection: ((Int?) -> Void)?
}
