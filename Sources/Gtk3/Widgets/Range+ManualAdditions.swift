import CGtk3

extension Range {
    public var value: Double { // has no property
        get {
            return gtk_range_get_value(castedPointer())
        }
        set {
            gtk_range_set_value(castedPointer(), newValue)
        }
    }
}
