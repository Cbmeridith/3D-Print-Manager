//
//  AppDelegate.swift
//  PrintManager
//
//  Created by Cody Meridith on 11/5/18.
//  Copyright © 2018 Cody Meridith. All rights reserved.
//

import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //TODO: move to config file
    var job: Job!
    let serverUrl = "http://192.168.1.253" //"octopi.local" doesn't work on my pi
    let apiKey = "75BD49121BBF41A5A0ED4E369C528769"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        job = Job(serverUrl: serverUrl, apiKey: apiKey)
        UIApplication.shared.setMinimumBackgroundFetchInterval(10)
        registerNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
 
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        // Check for new data.
        
        job.update()
        job.checkForCompletion()
        completionHandler(.newData)
    }



    func registerNotifications() {
        let notifCenter = UNUserNotificationCenter.current()
        let notifTypes: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notifCenter.requestAuthorization(options: notifTypes) {
            (granted, error) in
            if !granted {
                //user declined
            }
        }
        
        
        notifCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
    }

}

