//
//  UserDefaultsWrapper.swift
//  AudioFixer
//
//  Created by josemota on 31/07/2019.
//

import Foundation

class UserDefaultsWrapper {
    
    private static let inputSelectedKey: String = "inputSelectedKey"
    private static let outputSelectedKey: String = "outputSelectedKey"
    private static let isMasterKey: String = "isMasterKey"
    
    static func clearData() {
        
        UserDefaults.standard.set(nil, forKey: inputSelectedKey)
        UserDefaults.standard.set(nil, forKey: outputSelectedKey)
    }
    
    static func addInputSelectionName(_ name: String) {
        
        var index = 0
        var array = inputSelectionArray
        for item in array {
            if item == name {
                array.remove(at: index)
                break
            }
            index += 1
        }
        array.insert(name, at: 0)
        UserDefaults.standard.set(array, forKey: inputSelectedKey)
        NSLog("NEW input array \(array)")
    }
    
    static func addOutputSelectionName(_ name: String) {
        
        var index = 0
        var array = outputSelectionArray
        for item in array {
            if item == name {
                array.remove(at: index)
                break
            }
            index += 1
        }
        array.insert(name, at: 0)
        UserDefaults.standard.set(array, forKey: outputSelectedKey)
        NSLog("NEW output array \(array)")
    }
    
    static func setMaster(_ master: Bool) {
        UserDefaults.standard.set(master, forKey: isMasterKey)
    }
    
    static var inputSelectionArray: [String] {
        return UserDefaults.standard.array(forKey: inputSelectedKey) as? [String] ?? [String]()
    }
    
    static var outputSelectionArray: [String] {
        return UserDefaults.standard.array(forKey: outputSelectedKey) as? [String] ?? [String]()
    }
    
    static var isMaster: Bool {
        return UserDefaults.standard.bool(forKey: isMasterKey)
    }
}
