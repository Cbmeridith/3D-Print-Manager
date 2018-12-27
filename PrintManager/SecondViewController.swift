//
//  SecondViewController.swift
//  PrintManager
//
//  Created by Cody Meridith on 11/5/18.
//  Copyright © 2018 Cody Meridith. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var uLblAddress: UILabel!
    @IBOutlet weak var serverUrlField: UITextField!
    @IBOutlet weak var uLblApi: UILabel!
    @IBOutlet weak var apiKeyField: UITextField!
    @IBOutlet weak var uLblTheme: UILabel!
    @IBOutlet weak var themePicker: UISegmentedControl!
    
   
    @IBOutlet weak var tabBar: UITabBarItem!
    
    var settings: Settings!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings = Settings()
        updateTheme()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.serverUrlField.delegate = self
        self.apiKeyField.delegate = self

        
        
        // Update text fields to display saved values
        serverUrlField.text = settings.serverUrl!
        apiKeyField.text = settings.apiKey!
        themePicker.selectedSegmentIndex = settings.theme!
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // When Address field edited
    @IBAction func addressEdited(_ sender: UITextField) {
        settings.set(key: "serverUrl", value: serverUrlField.text)
    }

    
    // When API field edited
    @IBAction func apiEdited(_ sender: Any) {
        settings.set(key: "apiKey", value: apiKeyField.text)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("KEYBOARD GO AWAY!!!!") //lol
        textField.resignFirstResponder()
        return true;
    }
    
    
    @IBAction func themeChanged(_ sender: Any) {
        switch themePicker.selectedSegmentIndex {
        case 0:
            setLightTheme()
        case 1:
            setDarkTheme()
        case 2:
            setBlackTheme()
        default:
            setLightTheme()
        }
        
        // Save to settings
        settings.set(key: "theme", value: themePicker.selectedSegmentIndex)
    }
    
    
    func updateTheme() {
        if settings != nil && settings.theme != nil {
            switch settings.theme! {
                case 0: setLightTheme(); break;
                case 1: setDarkTheme(); break;
                case 2: setBlackTheme(); break;
                default: setLightTheme(); break;
            }
        }
    }
    
    
    func setLightTheme(){
        view.backgroundColor = UIColor.white
        uLblAddress.textColor = UIColor.black
        uLblApi.textColor = UIColor.black
        uLblTheme.textColor = UIColor.black
        themePicker.backgroundColor = UIColor.white
        themePicker.tintColor = UIColor.blue
        //themePicker.tintColor = UIColor.init(red: 0/255.0, green: 77/255.0, blue: 255/255.0, alpha: 1)
    }
    
    func setDarkTheme(){
        view.backgroundColor = UIColor.init(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
        uLblAddress.textColor = UIColor.white
        uLblApi.textColor = UIColor.white
        uLblTheme.textColor = UIColor.white
        themePicker.backgroundColor = UIColor.init(red: 40/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1)
        themePicker.tintColor = UIColor.orange
        //themePicker.tintColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 0/255.0, alpha: 1)
    }
    
    func setBlackTheme(){
        view.backgroundColor = UIColor.black
        uLblAddress.textColor = UIColor.white
        uLblApi.textColor = UIColor.white
        uLblTheme.textColor = UIColor.white
        themePicker.backgroundColor = UIColor.black
        themePicker.tintColor = UIColor.orange
        //themePicker.tintColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 0/255.0, alpha: 1)
    }
    
}

