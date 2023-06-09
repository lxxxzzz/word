//
//  Lesson.swift
//  word
//
//  Created by 小红李 on 2023/3/12.
//

import UIKit

class Lesson: NSObject {
    var id: Int?
    var number: Int?
    var name: String?
    var name_cn: String?
    var book_id: Int?
    var words: [Word] = [Word]()
    
    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        return lhs.id == rhs.id
    }
}

