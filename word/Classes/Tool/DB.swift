//
//  DB.swift
//  word
//
//  Created by 小红李 on 2023/3/18.
//

import UIKit
import FMDB

class DB: NSObject {
    public lazy var db: FMDatabase = {
        let db = FMDatabase(path: "\(path)/data/data.sqlite")
        return db
    }()
    
    static let shared = DB()
    
    private override init() {
        
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

extension DB {
    
    
    
    func allLessons(with book: Book) -> [Lesson] {
        
        guard let bookId = book.id else { return [] }
        
        var data = [Lesson]()
        if db.open() {
            print("DB打开成功")
            
            guard let result = db.executeQuery("SELECT * FROM t_lessons WHERE book_id = ?", withArgumentsIn: [bookId]) else { return data }
            
            while result.next() {
                let lesson = Lesson()
                lesson.id = Int(result.int(forColumn: "id"))
                lesson.book_id = Int(result.int(forColumn: "book_id"))
                lesson.number = Int(result.int(forColumn: "number"))
                lesson.name = result.string(forColumn: "name")
                lesson.name_cn = result.string(forColumn: "name_cn")
                lesson.book = book
                data.append(lesson)
                if let wordsResult = db.executeQuery("SELECT * FROM t_words WHERE book_id = ? AND lesson_id = ?", withArgumentsIn: [bookId, lesson.id]) {
                    
                    
                    while wordsResult.next() {
                        let word = Word()
                        word.lesson = lesson
                        word.book = book
                        word.id = Int(wordsResult.int(forColumn: "id"))
                        word.number = Int(wordsResult.int(forColumn: "number"))
                        word.chinese = wordsResult.string(forColumn: "chinese")
                        word.english = wordsResult.string(forColumn: "english")
                        
                        word.soundmark_uk = wordsResult.string(forColumn: "soundmark_uk")
                        word.soundmark_us = wordsResult.string(forColumn: "soundmark_us")
                        word.audio_url_uk = wordsResult.string(forColumn: "audio_url_uk")
                        word.audio_url_us = wordsResult.string(forColumn: "audio_url_us")
                        word.audio_path_uk = wordsResult.string(forColumn: "audio_path_uk")
                        word.audio_path_us = wordsResult.string(forColumn: "audio_path_us")
                        
                        lesson.words.append(word)
                    }
                }
            }
        } else {
            print("DB打开失败")
            
        }
        return data
    }
    
    func allBooks() -> [Book] {
        var data = [Book]()
        if db.open() {
            print("DB打开成功")
            
            if let result = db.executeQuery("SELECT * FROM t_books", withArgumentsIn: []) {
                while result.next() {
                    let book = Book()
                    book.id = Int(result.int(forColumn: "id"))
                    book.name = result.string(forColumn: "name")
                    data.append(book)
                }
            }
        } else {
            print("DB打开失败")
            
        }
        return data
    }
    
    
    func insertWords() {

//        insertWords(json: "新概念第一册", number: 1)
        insertWords(json: "新概念第二册", number: 2)
        insertWords(json: "新概念第三册", number: 3)
        insertWords(json: "新概念第四册", number: 4)
        
        print("已经全部插入")
    }
    
    func insertWords(json: String, number: Int) {
        if db.open() {
            print("DB打开成功")
            
            let path = "/Users/xiaohongli/Desktop/\(json).json"
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                
                let jsonDict = json as! Dictionary<String, Any>
                var max = 0
                if let maxresult = db.executeQuery("select min(id) as last from t_lessons where book_id = ?", withArgumentsIn: [number]) {
                
                    while maxresult.next() {
                        max = Int(maxresult.int(forColumn: "last")) - 1
                    }
                }

                if let data = jsonDict["data"] as? [[String:Any]] {
                    for item in data {
                        if let lesson_no = item["lesson_no"] as? Int, let list = item["list"] as? [[String:Any]] {
                            for word in list {
                                
                                let en_content = word["en_content"] as? String
                                let cn_content = word["cn_content"] as? String
                                let soundmark_us = word["am_phonogram"] as? String
                                let soundmark_uk = word["en_phonogram"] as? String
                                let audio_url_us = word["am_audio"] as? String
                                let audio_url_uk = word["en_audio"] as? String
                                let orders = word["orders"] as! Int

                                let sql = "INSERT INTO t_words(book_id, lesson_id, number, english, chinese,soundmark_us, soundmark_uk, audio_url_us, audio_url_uk, create_time, update_time) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                                
                                let result = db.executeUpdate(sql, withArgumentsIn: [number, lesson_no + max, orders+1, en_content, cn_content,soundmark_us,soundmark_uk,audio_url_us,audio_url_uk,"2023-3-18 15:00:00","2023-3-18 15:00:00"])
                                
                                if result {
                                    print("成功")
                                } else {
                                    print("失败")
                                }
                            }
                        }
                    }
                }

            } catch {
                
            }
            
        } else {
            print("DB打开失败")
        }
        
        db.close()
    }
}
