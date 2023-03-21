//
//  AppDelegate.swift
//  word
//
//  Created by 小红李 on 2023/3/12.
//

import UIKit
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        window?.rootViewController = BaseNavigationController(rootViewController: BookListViewController())
        window?.makeKeyAndVisible()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            
        }

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
        
        DB.shared.businessDB.close()
        DB.shared.wordDB.close()
    }

}

