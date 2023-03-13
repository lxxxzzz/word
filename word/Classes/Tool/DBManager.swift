//
//  DBManager.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit
import FMDB

class DBManager: NSObject {
    static let shared = DBManager()

    private lazy var path: String = {
//        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return "" }
//        return "\(path)/words.sqlite"
        
        var path = "/Users/xiaohongli/Desktop/word/sql/data.sqlite"
        
        return path
    }()
    
    lazy var db: FMDatabase = {
        var database = FMDatabase(path: path)
        return database
    }()
    
    lazy var queue: FMDatabaseQueue = {
        var queue = FMDatabaseQueue(path: path)!
        return queue
    }()
    
    private override init() {
        super.init()
        
        if db.open() {
            var sql = "CREATE TABLE IF NOT EXISTS t_books (book_id TEXT NOT NULL PRIMARY KEY, book_name TEXT, create_time TEXT, update_time TEXT);"
            if db.executeUpdate(sql, withArgumentsIn: []) {
                print("t_books表创建成功")
            }
            sql = "CREATE TABLE IF NOT EXISTS t_lessons (book_id TEXT, lesson_id TEXT NOT NULL, lesson_title TEXT, create_time TEXT, update_time TEXT, PRIMARY KEY(book_id, lesson_id));"
            if db.executeUpdate(sql, withArgumentsIn: []) {
                print("t_lessons表创建成功")
            }
            
            sql = "CREATE TABLE IF NOT EXISTS t_words (book_id TEXT, lesson_id TEXT NOT NULL, number TEXT, english TEXT NOT NULL, soundmark TEXT, chinese TEXT, create_time TEXT, update_time TEXT, PRIMARY KEY(english, book_id, lesson_id));"
            if db.executeUpdate(sql, withArgumentsIn: []) {
                print("t_words表创建成功")
            }
            
            db.close()
        } else {
            print("数据库打开失败")
        }
    }
    
    func insert(book: Book) {
        db.open()
        do {
            var result = try db.executeQuery("SELECT * FROM t_books WHERE book_id = ?", values: [book.id])
            if result.next() {
                return
            }
        } catch {
            
        }
        
        
        
        var result = db.executeUpdate("INSERT INTO t_books (book_id, book_name, create_time, update_time) VALUES(?, ?, ?, ?)", withArgumentsIn: [book.id, book.name, Date.sqlDate, Date.sqlDate])
        if result {
            print("book插入成功")
        }
        
        for lesson in book.lessons {
            result = db.executeUpdate("INSERT INTO t_lessons (lesson_id, book_id, lesson_title, create_time, update_time) VALUES(?, ?, ?, ?, ?)", withArgumentsIn: [lesson.id, book.id, lesson.title, Date.sqlDate, Date.sqlDate])
            if result {
//                print("\(lesson.title)插入成功\(lesson.words)")
            }
            
            for word in lesson.words {
                result = db.executeUpdate("INSERT INTO t_words (english, lesson_id, book_id, number, soundmark,  chinese, create_time, update_time) VALUES(?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [word.english, lesson.id, book.id, word.number, word.soundmark, word.chinese, Date.sqlDate, Date.sqlDate])
                if result {
//                    print("\(word.english)插入成功")
                }
            }
        }
        
        db.close()
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

extension Date {
    static var sqlDate: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd hh:MM:ss"
        return dateFormat.string(from: Date())
    }
}
