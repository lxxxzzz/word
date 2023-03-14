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
    var number: String?
    var english: String?
    var soundmark: String?
    var chinese: String?
}
