import Foundation

fileprivate let tag = "Defaults:"

public class SomeDefaults {
    private static let jsonDecoder = JSONDecoder()
    private static let jsonEncoder = JSONEncoder()
    
    private let userDefaults: UserDefaults
    
    public init(_ userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    public subscript<T: Codable>(index: SomeDefaultsKey<T>) -> T? {
        get {
            if let data = userDefaults.data(forKey: index.key) {
                do {
                    return try SomeDefaults.jsonDecoder.decode(T.self, from: data)
                } catch let err {
                    print(tag, err.localizedDescription)
                }
            }
            return index.defaultVal
        }
        set(newValue) {
            do {
                let data = try SomeDefaults.jsonEncoder.encode(newValue)
                userDefaults.set(data, forKey: index.key)
            } catch let err {
                print(tag, err.localizedDescription)
            }
        }
    }
}

public struct SomeDefaultsKey<T: Codable> {
    let defaultVal: T?
    let key: String
    
    public init(_ key: String, defaultVal: T?) {
        self.key = key
        self.defaultVal = defaultVal
    }
}
