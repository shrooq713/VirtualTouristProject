//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Shrooq Saleh on 02.07.19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DataController.shared.load()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        save()
    }

    func save(){
        try? DataController.shared.viewContext.save()
    }
}

