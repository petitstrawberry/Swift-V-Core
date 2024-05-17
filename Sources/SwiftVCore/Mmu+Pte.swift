extension Mmu {
    protocol Pte {
        var rawValue: UInt32 { get set }

        var valid: Bool { get set }
        var read: Bool { get set }
        var write: Bool { get set }
        var execute: Bool { get set }
        var user: Bool { get set }
        var global: Bool { get set }
        var accessed: Bool { get set }
        var dirty: Bool { get set }

        var ppn: UInt32 { get set }

        init(rawValue: UInt32)
    }
}

extension Mmu.Pte {
    var valid: Bool {
        get {
            return rawValue & 0x1 != 0
        }

        set {
            if newValue {
                rawValue |= 0x1
            } else {
                rawValue &= ~0x1
            }
        }
    }

    var read: Bool {
        get {
            return rawValue & 0x2 != 0
        }

        set {
            if newValue {
                rawValue |= 0x2
            } else {
                rawValue &= ~0x2
            }
        }
    }

    var write: Bool {
        get {
            return rawValue & 0x4 != 0
        }

        set {
            if newValue {
                rawValue |= 0x4
            } else {
                rawValue &= ~0x4
            }
        }
    }

    var execute: Bool {
        get {
            return rawValue & 0x8 != 0
        }

        set {
            if newValue {
                rawValue |= 0x8
            } else {
                rawValue &= ~0x8
            }
        }
    }

    var user: Bool {
        get {
            return rawValue & 0x10 != 0
        }

        set {
            if newValue {
                rawValue |= 0x10
            } else {
                rawValue &= ~0x10
            }
        }
    }

    var global: Bool {
        get {
            return rawValue & 0x20 != 0
        }

        set {
            if newValue {
                rawValue |= 0x20
            } else {
                rawValue &= ~0x20
            }
        }
    }

    var accessed: Bool {
        get {
            return rawValue & 0x40 != 0
        }

        set {
            if newValue {
                rawValue |= 0x40
            } else {
                rawValue &= ~0x40
            }
        }
    }

    var dirty: Bool {
        get {
            return rawValue & 0x80 != 0
        }

        set {
            if newValue {
                rawValue |= 0x80
            } else {
                rawValue &= ~0x80
            }
        }
    }
}
