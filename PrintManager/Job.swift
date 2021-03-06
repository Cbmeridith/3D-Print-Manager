//
//  Job.swift
//  PrintManager
//
//  Created by Cody Meridith on 11/5/18.
//  Copyright © 2018 Cody Meridith. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

struct FileDetail : Codable {
    let name: String?
    let origin: String?
    let size: Int?
    let date: Int?
    let path: String?
    let display: String?
    
    init() {
        name = ""
        origin = ""
        size = -1
        date = -1
        path = ""
        display = ""
    }
}


struct FilamentDetail : Codable {
    let length: Int?
    let volume: Double?
    
    init() {
        length = -1
        volume = -1.0
    }
}


struct JobDetail : Codable {
    let averagePrintTime: Double?
    let estimatedPrintTime: Double?
    let filament: FilamentDetail?
    let file: FileDetail?
    let lastPrintTime: Double?
    
    init() {
        file = FileDetail()
        estimatedPrintTime = -1
        filament = FilamentDetail()
        lastPrintTime = -1
        averagePrintTime = -1
    }
}


struct ProgressDetail : Codable {
    let completion: Double?
    let filepos: Int?
    let printTime: Int?
    let printTimeLeft: Int?
    let printTimeLeftOrigin: String?
    
    init() {
        completion = -1.0
        filepos = -1
        printTime = -1
        printTimeLeft = -1
        printTimeLeftOrigin = ""
    }
}


class Job : Codable {
    //codable properties
    var job: JobDetail?
    var progress: ProgressDetail?
    var state: String?
    
    //non-codable properties
    var serverUrl: String?
    var apiUrl: String?
    var apiKey: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case job
        case progress
        case state
    }
    
    
    init() {
        job = JobDetail()
        progress = ProgressDetail()
        state = ""
        serverUrl = ""
        apiUrl = ""
        apiKey = ""
    }
    
    
    init(settings: Settings) {
        self.serverUrl = settings.serverUrl!
        self.apiUrl = settings.serverUrl! + "/api"
        self.apiKey = settings.apiKey!
        job = JobDetail()
        progress = ProgressDetail()
        state = ""
        update()
    }
    
    
    func checkForCompletion() {
        var completion = 0.0
        if self.state != nil && !self.state!.contains("Offline") {
            completion = Double((self.progress?.completion)!)
            
            if(completion == 100.0) {
                let notifCenter = UNUserNotificationCenter.current()
                
                notifCenter.getDeliveredNotifications(completionHandler: { requests in
                    var printName = (self.job!.file!.display!)
                    printName = String(printName[..<printName.index(printName.endIndex, offsetBy: -6)])
                    
                    //check if a notification for this print has already been sent before sending another
                    var alreadySent = false
                    for request in requests {
                        if(request.request.identifier == "\(printName)") {
                            alreadySent = true
                            break
                        }
                    }
                    
                    if(!alreadySent) {
                        self.sendNotification(identifier: "\(printName)",
                                              title: "Your Print is Done!",
                                              body: "\(printName) has finished printing")
                    }
                    
                    
                })
            }
        }
        //debug, sends notification on every background refresh
        /*
        self.sendNotification(identifier: "test",
                              title: "Background Refresh!",
                              body: "A background refresh happened!")
        */
    }
    
    
    func update() {
        let url = URL(string: "\(self.apiUrl!)/job")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.addValue(apiKey!, forHTTPHeaderField: "X-Api-Key")
        
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
            let result = try! JSONDecoder().decode(Job.self, from: jsonData)
            
            self.job = result.job
            self.progress = result.progress
            self.state = result.state
            
            
            //check print completion and send notification only if app is in background
            if(UIApplication.shared.applicationState == .background) {
                self.checkForCompletion()
            }
        }
        task.resume()
    }
    
    
    func sendNotification(identifier: String!, title: String!, body: String!, sound: UNNotificationSound! = UNNotificationSound.default) {
        //create notification
        let notification = UNMutableNotificationContent()
        notification.title = title
        notification.body = body
        notification.sound = sound
        
        //send notification
        let date = Date(timeIntervalSinceNow: 1)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                    repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier,
            content: notification, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
                // Something went wrong
            }
        })
    }
}
