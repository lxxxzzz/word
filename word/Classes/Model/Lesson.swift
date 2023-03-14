//
//  Lesson.swift
//  word
//
//  Created by 小红李 on 2023/3/12.
//

import UIKit

class Lesson: NSObject {
    weak var book: Book?
    var title: String?
    var words: [Word] = [Word]()
    
    override var description: String {
        return title ?? super.description
    }
}
