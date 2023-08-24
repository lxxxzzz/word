//
//  APP.swift
//  word
//
//  Created by 小红李 on 2023/3/20.
//

import UIKit

class APP: NSObject {
    
    private let repeatCountKey = "__repeat_count_cache_key__"
    private let repeatIntervalKey = "__repeat_interval_cache_key__"
    private let deadlineKey = "__deadline_cache_key__"
    private let pronunciationKey = "__pronunciation_cache_key__"
    
    var repeatCount: Int = 2 {
        didSet {
            guard oldValue != repeatCount else { return }
            UserDefaults.standard.set(repeatCount, forKey: repeatCountKey)
            UserDefaults.standard.synchronize()
        }
    }
    var repeatInterval: Double = 2 {
        didSet {
            guard oldValue != repeatInterval else { return }
            UserDefaults.standard.set(repeatInterval, forKey: repeatIntervalKey)
            UserDefaults.standard.synchronize()
        }
    }
    var deadline: Double = 2 {
        didSet {
            guard oldValue != deadline else { return }
            UserDefaults.standard.set(deadline, forKey: deadlineKey)
            UserDefaults.standard.synchronize()
        }
    }
    /// 0:美式 1：英式
    var pronunciationType = 0 {
        didSet {
            guard oldValue != pronunciationType else { return }
            UserDefaults.standard.set(pronunciationType, forKey: pronunciationKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static let shared = APP()
    
    private override init() {
        super.init()
        
        let repeatCount: Int = UserDefaults.standard.integer(forKey: repeatCountKey)
        if repeatCount > 0 {
            self.repeatCount = repeatCount
        }

        if let interval: Double = UserDefaults.standard.object(forKey: repeatIntervalKey) as? Double {
            self.repeatInterval = interval
        }
        
        if let deadline: Double = UserDefaults.standard.object(forKey: deadlineKey) as? Double {
            self.deadline = deadline
        }

        pronunciationType = UserDefaults.standard.integer(forKey: pronunciationKey)
    }
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    // Optional
    func reset() {
        // Reset all properties to default value
    }
}
