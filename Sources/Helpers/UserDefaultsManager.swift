//
//  UserDefaultsManager.swift
//  Folders
//
//  Created by Cengizhan Tomak on 13.09.2023.
//

import Foundation

class UserDefaultsManager {
    static let Shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func Save<T: Encodable>(_ Object: T, ForKey Key: String) {
        guard let Encoded = try? JSONEncoder().encode(Object) else {
            return
        }
        userDefaults.set(Encoded, forKey: Key)
    }
    
    func Load<T: Decodable>(ForKey Key: String) -> T? {
        guard let Data = userDefaults.data(forKey: Key),
              let Decode = try? JSONDecoder().decode(T.self, from: Data) else {
            return nil
        }
        return Decode
    }
}
