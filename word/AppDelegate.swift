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
        window?.backgroundColor = .white
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback)
//            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
//        } catch {
//            
//        }
        
        return true
    }

}

