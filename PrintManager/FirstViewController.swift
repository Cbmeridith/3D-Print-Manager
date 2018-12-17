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
    
    
    //TODO: make these configurable
    let serverUrl = "http://192.168.1.253" //"octoprint.local" doesn't work on my pi
    let apiUrl = "http://192.168.1.253/api"
    let apiKey = "75BD49121BBF41A5A0ED4E369C528769"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        let url = URL(string: "\(apiUrl)/job")!

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
        
        let timeRemaining = Double((detail.progress?.printTimeLeft)!) //in seconds
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
    
    
    
    

}

