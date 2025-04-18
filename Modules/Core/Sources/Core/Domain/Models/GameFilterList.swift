//
//  GameFilterList.swift
//  GimPlay
//
//  Created by Wildan on 10/03/25.
//

import Foundation

public enum GameFilterList: CaseIterable {
case lucky, new, update
    public static func fromIndex(_ idx: Int) -> String {
        switch idx {
        case 0: return "lucky"
        case 1: return "released"
        case 2: return "updated"
        default: return "lucky"
        }
    }
}
