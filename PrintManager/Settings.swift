//
//  Settings.swift
//  PrintManager
//
//  Created by Cody Meridith on 12/22/18.
//  Copyright © 2018 Cody Meridith. All rights reserved.
//

import Foundation


class Settings {
    
    var serverUrl: String?
    var apiUrl: String?
    var apiKey: String?
    var theme: Int?
    
    private var settings: NSMutableDictionary!
    private var filePath: String!
    
    init() {
        update()
    }
    
    
    func update() {
        // Copy plist file
        let bundlePath = Bundle.main.path(forResource: "Settings", ofType: "plist")
        //print(bundlePath, "\n") //prints the correct path
        let fileManager = FileManager.default
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("Settings.plist")
        filePath = fullDestPath?.path
        //print(fileManager.fileExists(atPath: bundlePath!)) // prints true
        
        // TODO check version number and delete copy in documents if it doens't match
        /*
        do {
            if FileManager.default.fileExists(atPath: filePath!) {
                try FileManager.default.removeItem(atPath: filePath!)
            }
        } catch {
            print(error)
        }
        */
        do{
            try fileManager.copyItem(atPath: bundlePath!, toPath: filePath!)
        }catch{
            print("\n")
            print(error) // file already exists (most likely)
        }
        
        // Read settings plist
        settings = NSMutableDictionary(contentsOfFile: filePath!)
        serverUrl = (settings?.value(forKey: "serverUrl") as? String)!
        serverUrl = serverUrl!.components(separatedBy: .whitespaces).joined() // remove white space
        apiKey = (settings?.value(forKey: "apiKey") as? String)!
        theme = (settings?.value(forKey: "theme") as? Int)!
        
        
        /*
         print("URL: ", serverUrl!)
         print("API:  ", apiKey!)
         print("Theme: ", theme)
         */
        
        
        // Make API URL
        apiUrl = serverUrl!+"/api"
        //print("API URL: ", apiUrl!)
    }
    
    
    func set(key: String!, value: String!) {
        settings?[key] = value
        settings?.write(toFile: filePath!, atomically: true)
    }
    
    
    func set(key: String!, value: Int!) {
        settings?[key] = value
        settings?.write(toFile: filePath!, atomically: true)
    }
}
