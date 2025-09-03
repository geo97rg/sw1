import Foundation

enum Base64Helper {
    /// Кодировать строку в Base64
    static func encode(_ text: String) -> String {
        return Data(text.utf8).base64EncodedString()
    }

    /// Декодировать Base64 в строку
    static func decode(_ base64: String) -> String? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
