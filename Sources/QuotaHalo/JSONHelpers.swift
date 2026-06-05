import Foundation

func dictionary(_ object: [String: Any], _ key: String) -> [String: Any]? {
    object[key] as? [String: Any]
}

func string(_ object: [String: Any], _ key: String) -> String? {
    if let value = object[key] as? String, !value.isEmpty {
        return value
    }
    if let value = object[key] as? NSNumber {
        return value.stringValue
    }
    return nil
}

func number(_ object: [String: Any], _ key: String) -> Double? {
    if let value = object[key] as? Double {
        return value
    }
    if let value = object[key] as? Int {
        return Double(value)
    }
    if let value = object[key] as? NSNumber {
        return value.doubleValue
    }
    if let value = object[key] as? String {
        return Double(value)
    }
    return nil
}

func integer(_ object: [String: Any], _ key: String) -> Int? {
    if let value = object[key] as? Int {
        return value
    }
    if let value = object[key] as? NSNumber {
        return value.intValue
    }
    if let value = object[key] as? String {
        return Int(value)
    }
    return nil
}

func bool(_ object: [String: Any], _ key: String) -> Bool? {
    if let value = object[key] as? Bool {
        return value
    }
    if let value = object[key] as? NSNumber {
        return value.boolValue
    }
    if let value = object[key] as? String {
        switch value.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    return nil
}

func requestID(_ value: Any?) -> Int? {
    if let int = value as? Int {
        return int
    }
    if let number = value as? NSNumber {
        return number.intValue
    }
    if let string = value as? String {
        return Int(string)
    }
    return nil
}

func epochDate(_ value: Double?) -> Date? {
    guard let value, value > 0 else { return nil }
    if value > 10_000_000_000 {
        return Date(timeIntervalSince1970: value / 1_000)
    }
    return Date(timeIntervalSince1970: value)
}

func flexibleDate(_ value: Any?) -> Date? {
    if let number = value as? NSNumber {
        return epochDate(number.doubleValue)
    }
    if let value = value as? Double {
        return epochDate(value)
    }
    if let value = value as? String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: value) {
            return date
        }
        if let number = Double(value) {
            return epochDate(number)
        }
    }
    return nil
}
