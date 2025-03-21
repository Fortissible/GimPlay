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
    
    static var name: String? {
        get {
            return UserDefaults.standard.string(forKey: nameKey) ?? "Wildan Fajri Alfarabi"
        } set(name) {
            UserDefaults.standard.set(name, forKey: nameKey)
        }
    }
    
    static var profession: String? {
        get {
            return UserDefaults.standard.string(forKey: professionKey) ?? "Software Engineer"
        } set {
            UserDefaults.standard.set(newValue, forKey: professionKey)
        }
    }
    
    static var desc: String? {
        get {
            return UserDefaults.standard.string(forKey: descKey) ?? "Hello I'm Wildan, graduate from Bogor Agricultural University's Computer Science Major. I enjoy developing software or solutions to automate repetitive chores or challenges, overcoming new challenge and learn new things to improve my hard and soft skills. I have a lot of expertise creating programs and mobile/web application then incorporating machine learning into them using languages like Python, Kotlin, Dart, Python, JavaScript, C++ and R. In order to come up with the best answer to the issue, I also knowledgeable with UI/UX design principles and implementations. Another hobby that I love is drawing illustrations."
        } set {
            UserDefaults.standard.set(newValue, forKey: descKey)
        }
    }
    
    // Recommended using local storage file manager
    static var image: Data? {
        get {
            return UserDefaults.standard.data(forKey: imageKey)
        } set(imageData) {
            UserDefaults.standard.set(imageData, forKey: imageKey)
        }
    }
    
    static func sync() {
        UserDefaults.standard.synchronize()
    }
}
