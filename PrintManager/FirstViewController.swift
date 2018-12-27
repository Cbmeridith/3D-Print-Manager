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
    //let serverUrl = "http://192.168.1.253" //"octopi.local" doesn't work on my pi
    //let apiUrl = "http://192.168.1.253/api"
    //let apiKey = "75BD49121BBF41A5A0ED4E369C528769" // Cody
    //let apiKey = "57C66C82F717434F9096D74ED7598F24" // Cameron
    
    var settings: Settings!
    var job: Job!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = Settings()
        updateTheme()
        job = Job(settings: settings)
        
        updateCurrentPrintInfo()
        
        //initialize camera
        uWebCamera.scrollView.isScrollEnabled = false
        uWebCamera.isOpaque = false
        if let url = URL(string:"\(String(describing: settings.serverUrl!))/webcam/?action=snapshot") {
            let request = URLRequest(url: url)
            uWebCamera.load(request)
        }
        updateCameraFeed()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if settings == nil {
            settings = Settings()
        }
        else {
            settings.update()
        }
        updateTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func updateCurrentPrintInfo() {
        job.update()
        DispatchQueue.main.async {
            self.updateJobLabels()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateCurrentPrintInfo()
        }
    }
    
    
    func updateCameraFeed() {
        uWebCamera.reload()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateCameraFeed()
        }
    }
    
    
    func updateJobLabels() {
        var timeRemaining = -1.0
        let oneHourSeconds = 3600.0
        self.uLblCurrentAction.isHidden = true
        
        if(job.progress?.completion != nil && job.progress?.completion != -1.0) {
            let completion = String(format:"%.2f", (job.progress?.completion)!)
            
            if job.progress?.printTimeLeft != nil {
                timeRemaining = Double((job.progress?.printTimeLeft)!) //in seconds
            }
            
            let timeElapsed = Double((job.progress?.printTime)!)
            
            
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
                if minutes != "-0"{
                    self.uLblTimeRemaining.text = "Est. Time Remaining: \(minutes)m"
                } else {
                    self.uLblTimeRemaining.text = "Est. Time Remaining: Unknown"
                }
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
        uLblCurrentAction.textColor = UIColor.init(red: 0/255.0, green: 77/255.0, blue: 255/255.0, alpha: 1)
        uLblTimeElapsed.textColor = UIColor.black
        uLblTimeRemaining.textColor = UIColor.black
        uLblDateCompletion.textColor = UIColor.black
        uLblPrintCompletion.textColor = UIColor.black
    }
    
    func setDarkTheme(){
        view.backgroundColor = UIColor.init(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1)
        uLblCurrentAction.textColor = UIColor.init(red: 255/255.0, green: 77/255.0, blue: 0/255.0, alpha: 1)
        uLblTimeElapsed.textColor = UIColor.white
        uLblTimeRemaining.textColor = UIColor.white
        uLblDateCompletion.textColor = UIColor.white
        uLblPrintCompletion.textColor = UIColor.white
        var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
    }
    
    func setBlackTheme(){
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
