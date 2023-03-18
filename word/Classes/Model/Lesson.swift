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
    weak var book: Book?
    var words: [Word] = [Word]()
    
}
