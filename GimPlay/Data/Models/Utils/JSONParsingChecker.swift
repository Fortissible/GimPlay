//
//  JSONParsingChecker.swift
//  GimPlay
//
//  Created by Wildan on 12/03/25.
//

import Foundation

func JSONParsingChecker<T: Decodable>(classes: T.Type, data: Data) {
    do {
        _ = try JSONDecoder().decode(classes.self, from: data)
    } catch let DecodingError.dataCorrupted(context) {
        print("Data Corrupted Error: \(context)")
    } catch let DecodingError.keyNotFound(key, context) {
        print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
    } catch let DecodingError.typeMismatch(type, context) {
        print("Type mismatch for type \(type): \(context.debugDescription)")
    } catch let DecodingError.valueNotFound(type, context) {
        print("Value not found for type \(type): \(context.debugDescription)")
    } catch {
        print("Decoding Error: \(error)")
    }
}
