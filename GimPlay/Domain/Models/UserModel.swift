//
//  UserModel.swift
//  GimPlay
//
//  Created by Wildan on 21/03/25.
//

import Foundation

struct UserModel {
    static let nameKey = "name"
    static let professionKey = "profession"
    static let descKey = "desc"
    static let imageKey = "image"
    
    static var name: String {
        get {
            return UserDefaults.standard.string(forKey: nameKey) ?? "Anonymous"
        } set(name) {
            UserDefaults.standard.set(name, forKey: nameKey)
        }
    }
    
    static var profession: String {
        get {
            return UserDefaults.standard.string(forKey: professionKey) ?? "Sibuk Ngoding"
        } set {
            UserDefaults.standard.set(newValue, forKey: professionKey)
        }
    }
    
    static var desc: String {
        get {
            return UserDefaults.standard.string(forKey: descKey) ?? "Tolak RUU TNI!"
        } set {
            UserDefaults.standard.set(newValue, forKey: descKey)
        }
    }
    
    // Recommended using local storage file manager
    static var image: Data {
        get {
            return UserDefaults.standard.data(forKey: imageKey) ?? Data()
        } set(imageData) {
            UserDefaults.standard.set(imageData, forKey: imageKey)
        }
    }
    
    static func sync() {
        UserDefaults.standard.synchronize()
    }
}
