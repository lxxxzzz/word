//
//  Word.swift
//  word
//
//  Created by 小红李 on 2023/3/12.
//

import UIKit
import AVFoundation

class Word: NSObject {
    weak var book: Book?
    weak var lesson: Lesson?
    
    var id: Int?

    var number: Int?
    var english: String?
    var chinese: String?
    
    var soundmark_us: String?
    var soundmark_uk: String?
    var audio_url_us: String?
    var audio_url_uk: String?
    var audio_path_us: String?
    var audio_path_uk: String?
}
