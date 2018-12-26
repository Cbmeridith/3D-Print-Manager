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
import UserNotifications


class FirstViewController: UIViewController, WKUIDelegate {
    @IBOutlet weak var uLblPrintCompletion: UILabel!
    @IBOutlet weak var uLblCurrentAction: UILabel!
    @IBOutlet weak var uLblTimeRemaining: UILabel!
    @IBOutlet weak var uLblTimeElapsed: UILabel!
    @IBOutlet weak var uLblDateCompletion: UILabel!
    @IBOutlet var uProgPrint: UIView!
    @IBOutlet weak var uWebCamera: WKWebView!
    
    
    //TODO: make these configurable
    
    
    var job: Job!
    let serverUrl = "http://192.168.1.253" //"octopi.local" doesn't work on my pi
    let apiKey = "75BD49121BBF41A5A0ED4E369C528769"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        job = Job(serverUrl: serverUrl, apiKey: apiKey)
        updateCurrentPrintInfo()
        
        //initialize camera
        uWebCamera.scrollView.isScrollEnabled = false
        if let url = URL(string:"\(serverUrl)/webcam/?action=snapshot") {
            let request = URLRequest(url: url)
            uWebCamera.load(request)
        }
        updateCameraFeed()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
        
        if(job.progress?.completion != -1) {
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
    }
    
}

