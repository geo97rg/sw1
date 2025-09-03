import Foundation
import UIKit

struct DeviceInfo: Codable {
    let uuid: String       // сохранённый UUID
    let model_id: String   // модель устройства (например, "iPhone13,2")
    let os: String         // версия ОС (например, "iOS 17.6.1")
    let lang: String       // язык устройства (например, "en_EN")
    let rg: String         // регион устройства (например, "US")
    let bld: String        // build ОС (например, "21G82")
}

final class DeviceInfoManager {
    static let shared = DeviceInfoManager()
    private init() {}

    private let uuidKey = "device_uuid"

    /// Сохраняем UUID один раз
    private func getOrCreateUUID() -> String {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: uuidKey) {
            return existing
        } else {
            let new = UUID().uuidString
            defaults.set(new, forKey: uuidKey)
            return new
        }
    }

    /// Получаем build версии ОС (например, "21G82")
    private func getOSBuildVersion() -> String {
        var size: Int = 0
        sysctlbyname("kern.osversion", nil, &size, nil, 0)

        var build = [CChar](repeating: 0, count: size)
        sysctlbyname("kern.osversion", &build, &size, nil, 0)

        return String(cString: build)
    }

    /// Собираем полную инфу
    func getInfo() -> DeviceInfo {
        let uuid = getOrCreateUUID()

        // модель устройства (machine string)
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelID = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }

        let osVersion = "iOS " + UIDevice.current.systemVersion
        let lang = Locale.current.identifier
        let rg = Locale.current.regionCode ?? "??"
        let build = getOSBuildVersion()

        return DeviceInfo(
            uuid: uuid,
            model_id: modelID,
            os: osVersion,
            lang: lang,
            rg: rg,
            bld: build
        )
    }
}
