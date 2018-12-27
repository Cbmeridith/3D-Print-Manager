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
    var settings: Settings!
    var job: Job!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        settings = Settings()
        job = Job(settings: settings)
        UIApplication.shared.setMinimumBackgroundFetchInterval(1)
        registerNotifications()
        
        // Set TabBar color
        let tbController = self.window!.rootViewController as! UITabBarController
        tbController.tabBar.isTranslucent = true
        tbController.tabBar.barTintColor = UIColor.orange
        tbController.tabBar.tintColor = UIColor.white
        tbController.tabBar.unselectedItemTintColor = UIColor.black

        
        
        // Set Status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.orange
        }

        
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

