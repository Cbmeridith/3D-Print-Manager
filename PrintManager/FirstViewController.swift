//
//  FirstViewController.swift
//  PrintManager
//
//  Created by Cody Meridith on 11/5/18.
//  Copyright © 2018 Cody Meridith. All rights reserved.
//

import UIKit
import Foundation
import WebKit

class FirstViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var uLblPrintCompletion: UILabel!
    @IBOutlet weak var uLblCurrentAction: UILabel!
    @IBOutlet weak var uLblTimeRemaining: UILabel!
    @IBOutlet weak var uLblTimeElapsed: UILabel!
    @IBOutlet weak var uLblDateCompletion: UILabel!
    @IBOutlet var uProgPrint: UIView!
    @IBOutlet weak var uWebCamera: WKWebView!
    
    
    //TODO: make these configurable -- DONE -- double check
    //let serverUrl = "http://192.168.1.253" //"octoprint.local" doesn't work on my pi
    //let apiUrl = "http://192.168.1.253/api"
    //let apiKey = "75BD49121BBF41A5A0ED4E369C528769" // Cody
    //let apiKey = "57C66C82F717434F9096D74ED7598F24" // Cameron
    
    var serverUrl: String!
    var apiUrl: String!
    var apiKey: String!
    var theme: Int!
    var pathToSettings: String!
    var settings: NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSettings()
        updateCurrentPrintInfo()
        
        //initialize camera
        uWebCamera.scrollView.isScrollEnabled = false
        if let url = URL(string:"\(serverUrl)/webcam/?action=snapshot") {
            let request = URLRequest(url: url)
            uWebCamera.load(request)
        }
        
        updateCameraFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getSettings() {
        // Copy plist file
        let bundlePath = Bundle.main.path(forResource: "Settings", ofType: "plist")
        //print(bundlePath, "\n") //prints the correct path
        let fileManager = FileManager.default
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let fullDestPath = NSURL(fileURLWithPath: destPath).appendingPathComponent("Settings.plist")
        let fullDestPathString = fullDestPath?.path
        //print(fileManager.fileExists(atPath: bundlePath!)) // prints true
        pathToSettings = fullDestPathString
        
        // TODO check version number and delete copy in documents if it doens't match
        
        do{
            try fileManager.copyItem(atPath: bundlePath!, toPath: fullDestPathString!)
        }catch{
            print("\n")
            print(error) // file already exists (most likely)
        }
        
        // Read settings plist
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        serverUrl = (settings?.value(forKey: "serverUrl") as? String)!
        serverUrl = serverUrl.components(separatedBy: .whitespaces).joined() // remove white space
        apiKey = (settings?.value(forKey: "apiKey") as? String)!
        theme = (settings?.value(forKey: "theme") as? Int)!
        print("URL: ", serverUrl!)
        print("API:  ", apiKey!)
        print("Theme: ", theme)
        
        // Change theme
        switch theme {
        case 0:
            setLightTheme()
        case 1:
            setDarkTheme()
        default:
            setLightTheme()
        }
        
        // Make API URL
        apiUrl = serverUrl!+"/api"
        //print("API URL: ", apiUrl!)
        
    }
    
    
    func updateCurrentPrintInfo() {
        let url = URL(string: "\(apiUrl!)/job")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error!)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print(response!)
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            //print(responseString)
            let jsonData = responseString!.data(using: .utf8)!
            let job = try! JSONDecoder().decode(Job.self, from: jsonData)
            
            DispatchQueue.main.async {
                self.updateJobLabels(detail: job)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.updateCurrentPrintInfo()
            }
        }
        task.resume()
    }
    
    
    func updateCameraFeed() {
        uWebCamera.reload()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateCameraFeed()
        }
    }
    
    
    func updateJobLabels(detail: Job) {
        let oneHourSeconds = 3600.0
        self.uLblCurrentAction.isHidden = true
        let completion = String(format:"%.2f", (detail.progress?.completion)!)
        
        let timeRemaining = Double((detail.progress?.printTimeLeft)!) //in seconds   //nil if unknown yet - crashes
        let timeElapsed = Double((detail.progress?.printTime)!)
        
        
        if timeElapsed < oneHourSeconds {
            let minutes = String(format:"%.0f", timeElapsed / 60.0)
            self.uLblTimeElapsed.text = "Time Elapsed: \(minutes)m"
        }
        else {
            let hours = String(format:"%.1f", timeElapsed / 3600)
            self.uLblTimeElapsed.text = "Time Elapsed: \(hours)h"
        }
        
        
        if timeRemaining < oneHourSeconds {
            let minutes = String(format:"%.0f", timeRemaining / 60.0)
            self.uLblTimeRemaining.text = "Est. Time Remaining: \(minutes)m"
        }
        else {
            let hours = String(format:"%.1f", timeRemaining / 3600)
            self.uLblTimeRemaining.text = "Est. Time Remaining: \(hours)h"
        }
        
        self.uLblPrintCompletion.text = "Job Completion: \(completion)%"
        
        
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .second, value: Int(timeRemaining), to: Date())
        
        var endHour = String(calendar.component(.hour, from: endDate!))
        var endMinute = String(calendar.component(.minute, from: endDate!))
        
        if endHour.count == 1 {
            endHour = "0\(endHour)"
        }
        if endMinute.count == 1 {
            endMinute = "0\(endMinute)"
        }
        
        self.uLblDateCompletion.text = "Est. Completion Date: \(endHour):\(endMinute)"
        
        
        
        self.uLblPrintCompletion.isHidden = false
        self.uLblTimeRemaining.isHidden = false
        self.uLblTimeElapsed.isHidden = false
        self.uLblDateCompletion.isHidden = false
        
    }
    
    
    func setLightTheme(){
        view.backgroundColor = UIColor.white
        uLblCurrentAction.textColor = UIColor.init(red: 0/255.0, green: 77/255.0, blue: 255/255.0, alpha: 1)
        uLblTimeElapsed.textColor = UIColor.black
        uLblTimeRemaining.textColor = UIColor.black
        uLblDateCompletion.textColor = UIColor.black
        uLblPrintCompletion.textColor = UIColor.black
    }
    
    func setDarkTheme(){
        view.backgroundColor = UIColor.black
        uLblCurrentAction.textColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 0/255.0, alpha: 1)
        uLblTimeElapsed.textColor = UIColor.white
        uLblTimeRemaining.textColor = UIColor.white
        uLblDateCompletion.textColor = UIColor.white
        uLblPrintCompletion.textColor = UIColor.white
        var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
    }
    
    
}

