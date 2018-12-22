//
//  SecondViewController.swift
//  PrintManager
//
//  Created by Cody Meridith on 11/5/18.
//  Copyright © 2018 Cody Meridith. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate {

    // Variables
    var serverUrl: String!
    var apiKey: String!
    var theme: Int!
    var pathToSettings: String!
    var settings: NSMutableDictionary!
    
    @IBOutlet weak var uLblAddress: UILabel!
    @IBOutlet weak var serverUrlField: UITextField!
    @IBOutlet weak var uLblApi: UILabel!
    @IBOutlet weak var apiKeyField: UITextField!
    @IBOutlet weak var uLblTheme: UILabel!
    @IBOutlet weak var themePicker: UISegmentedControl!
    
   
    @IBOutlet weak var tabBar: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.serverUrlField.delegate = self
        self.apiKeyField.delegate = self
        
        // get path to Settings plist
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("Settings.plist")
        let fullDestPathString = fullDestPath?.path
        pathToSettings = fullDestPathString
        
        //read settings plist
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        serverUrl = (settings?.value(forKey: "serverUrl") as? String)!
        apiKey = (settings?.value(forKey: "apiKey") as? String)!
        theme = (settings?.value(forKey: "theme") as? Int)!
        
        // Change theme
        switch theme {
        case 0:
            setLightTheme()
        case 1:
            setDarkTheme()
        default:
            setLightTheme()
        }
        
        // Update text fields to display saved values
        serverUrlField.text = serverUrl
        apiKeyField.text = apiKey
        themePicker.selectedSegmentIndex = theme
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // When Address field edited
    @IBAction func addressEdited(_ sender: UITextField) {
        settings?["serverUrl"] = serverUrlField.text
        settings?.write(toFile: pathToSettings!, atomically: true)
    }

    // When API field edited
    @IBAction func apiEdited(_ sender: Any) {
        settings?["apiKey"] = apiKeyField.text
        settings?.write(toFile: pathToSettings!, atomically: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("KEYBOARD GO AWAY!!!!")
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func themeChanged(_ sender: Any) {
        switch themePicker.selectedSegmentIndex {
        case 0:
            setLightTheme()
        case 1:
            setDarkTheme()
        default:
            setLightTheme()
        }
        
        // Save to settings
        settings?["theme"] = themePicker.selectedSegmentIndex
        settings?.write(toFile: pathToSettings!, atomically: true)
    }
    
    func setLightTheme(){
        view.backgroundColor = UIColor.white
        uLblAddress.textColor = UIColor.black
        uLblApi.textColor = UIColor.black
        uLblTheme.textColor = UIColor.black
        themePicker.backgroundColor = UIColor.white
        themePicker.tintColor = UIColor.init(red: 0/255.0, green: 77/255.0, blue: 255/255.0, alpha: 1)
        
        // below here doesn't work
        var preferredStatusBarStyle: UIStatusBarStyle {
            return .default
        }
        self.tabBar.badgeColor = UIColor.init(red: 0/255.0, green: 77/255.0, blue: 255/255.0, alpha: 1)
        UITabBar.appearance().backgroundColor = UIColor.lightGray
    }
    
    func setDarkTheme(){
        view.backgroundColor = UIColor.black
        uLblAddress.textColor = UIColor.white
        uLblApi.textColor = UIColor.white
        uLblTheme.textColor = UIColor.white
        themePicker.backgroundColor = UIColor.black
        themePicker.tintColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 0/255.0, alpha: 1)
        
        // below here doesn't work
        var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        self.tabBar.badgeColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 0/255.0, alpha: 1)
        UITabBar.appearance().backgroundColor = UIColor.black
    }
    
}

