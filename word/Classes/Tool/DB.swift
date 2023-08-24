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
        let sourcePath = "\(bundlePath)/data/data.sqlite"
        var destinationPath = "\(cachePath)/db"
        do {
            let manager = FileManager.default

            if !manager.fileExists(atPath: destinationPath) {
                try manager.createDirectory(at: URL(fileURLWithPath: destinationPath), withIntermediateDirectories: true, attributes: nil)
            }
            
            destinationPath.append("/data.sqlite")
            
            if !manager.fileExists(atPath: destinationPath) {
                try manager.copyItem(atPath: sourcePath, toPath: destinationPath)
            } else {
                print("已经copy过了，无需拷贝")
            }
            
        } catch {
            print("db文件操作失败")
        }

        let db = FMDatabase(path: destinationPath)
        if !db.open() {
            print("db数据库打开失败")
        }
        return db
    }()
    
    static let shared = DB()
    
    private override init() {
        super.init()
        createTable()
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
    func createTable() {
        let sql = "CREATE TABLE IF NOT EXISTS t_error_words(word_id INTEGER PRIMARY KEY, count INTEGER NOT NULL);"
        if db.executeUpdate(sql, withArgumentsIn: []) {
            print("t_error_words表创建成功")
        } else {
            print("t_error_words表创建失败")
        }
    }
    
    func insert(error wordId: Int) {
        var sql = "SELECT count FROM t_error_words WHERE word_id = ?"
        if let result = db.executeQuery(sql, withArgumentsIn: [wordId]), result.next() {
            let count = result.int(forColumn: "count")
            sql = "UPDATE t_error_words SET count = ? WHERE word_id = ?;"
            if db.executeUpdate(sql, withArgumentsIn: [count + 1, wordId]) {
                print("更新成功")
            } else {
                print("更新失败")
            }
        } else {
            sql = "INSERT INTO t_error_words(word_id, count) VALUES(?, 1);"
            if db.executeUpdate(sql, withArgumentsIn: [wordId]) {
                print("更新成功")
            } else {
                print("更新失败")
            }
        }
    }
    
    func insert(error wordIds: [Int]) {
        for wordId in wordIds {
            insert(error: wordId)
        }
    }
    
    func delete(error wordId: Int) {
        let sql = "DELETE FROM t_error_words WHERE word_id = ?"
        let flag = db.executeUpdate(sql, withArgumentsIn: [wordId])
        if flag {
            print("\(wordId)删除成功")
        } else {
            print("\(wordId)删除失败")
        }
    }
    
    func allErrorWords() -> [Int : Int] {
        var words = [Int : Int]()
        let sql = "SELECT * FROM t_error_words"
        guard let result = db.executeQuery(sql, withArgumentsIn: []) else {
            return words
        }
        while result.next() {
            let word_id = Int(result.int(forColumn: "word_id"))
            let count = Int(result.int(forColumn: "count"))
            words[word_id] = count
        }
        return words
    }
}

extension DB {
    
    func get(bookBy bookId: Int) -> Book? {
        let sql = "SELECT * FROM t_books WHERE id = ?"
        guard let result = db.executeQuery(sql, withArgumentsIn: [bookId]) else {
            return nil
        }
        while result.next() {
            let book = Book()
            book.id = Int(result.int(forColumn: "id"))
            book.name = result.string(forColumn: "name")
            return book
        }
        return nil
    }
    
    func get(lessonBy lessonId: Int?) -> Lesson? {
        guard let lessonId = lessonId else { return nil }
        let sql = "SELECT * FROM t_lessons WHERE id = ?"
        guard let result = db.executeQuery(sql, withArgumentsIn: [lessonId]) else {
            return nil
        }
        while result.next() {
            let lesson = Lesson()
            lesson.id = Int(result.int(forColumn: "id"))
            lesson.book_id = Int(result.int(forColumn: "book_id"))
            lesson.number = Int(result.int(forColumn: "number"))
            lesson.name = result.string(forColumn: "name")
            lesson.name_cn = result.string(forColumn: "name_cn")
            return lesson
        }
        return nil
    }
    
    func get(wordsBy wordIds: [Int]) -> [Word] {
        var words = [Word]()
        var ids = ""
        for wordId in wordIds {
            if ids.isEmpty {
                ids.append("\(wordId)")
            } else {
                ids.append(", \(wordId)")
            }
        }
        let sql = "SELECT * FROM t_words WHERE id in(\(ids))"
        guard let result = db.executeQuery(sql, withArgumentsIn: []) else {
            return words
        }
        
        while result.next() {
            let word = Word()
            word.id = Int(result.int(forColumn: "id"))
            word.book_id = Int(result.int(forColumn: "book_id"))
            word.lesson_id = Int(result.int(forColumn: "lesson_id"))
            word.number = Int(result.int(forColumn: "number"))
            word.chinese = result.string(forColumn: "chinese")
            word.english = result.string(forColumn: "english")
            word.soundmark_uk = result.string(forColumn: "soundmark_uk")
            word.soundmark_us = result.string(forColumn: "soundmark_us")
            word.audio_url_uk = result.string(forColumn: "audio_url_uk")
            word.audio_url_us = result.string(forColumn: "audio_url_us")
            word.audio_path_uk = result.string(forColumn: "audio_path_uk")
            word.audio_path_us = result.string(forColumn: "audio_path_us")
            words.append(word)
        }
        
        return words
    }
    
    func get(wordBy wordId: Int?) -> Word? {
        guard let wordId = wordId else { return nil }
        let sql = "SELECT * FROM t_words WHERE id = ?"
        guard let result = db.executeQuery(sql, withArgumentsIn: [wordId]) else { return nil }
        
        while result.next() {
            let word = make(wordBy: result)
            return word
        }
        
        return nil
    }
    
    func get(wordsBy lessonId: Int?) -> [Word] {
        var words = [Word]()
        guard let lessonId = lessonId else { return words }
        
        let sql = "SELECT * FROM t_words WHERE lesson_id = ?"
        guard let result = db.executeQuery(sql, withArgumentsIn: [lessonId]) else {
            return words
        }
        
        while result.next() {
            let word = make(wordBy: result)
            words.append(word)
        }
        return words
    }
    
    func get(lessonsBy bookId: Int?) -> [Lesson] {
        var lessons = [Lesson]()
        guard let bookId = bookId else { return lessons }
        
        let sql = "SELECT * FROM t_lessons WHERE book_id = ?"
        guard let result = db.executeQuery(sql, withArgumentsIn: [bookId]) else {
            return lessons
        }

        while result.next() {
            let lesson = Lesson()
            lesson.id = Int(result.int(forColumn: "id"))
            lesson.book_id = Int(result.int(forColumn: "book_id"))
            lesson.number = Int(result.int(forColumn: "number"))
            lesson.name = result.string(forColumn: "name")
            lesson.name_cn = result.string(forColumn: "name_cn")
            lessons.append(lesson)
        }

        return lessons
    }

    func allBooks() -> [Book] {
        var books = [Book]()
        let sql = "SELECT * FROM t_books"
        guard let result = db.executeQuery(sql, withArgumentsIn: []) else {
            return books
        }
        
        while result.next() {
            let book = Book()
            book.id = Int(result.int(forColumn: "id"))
            book.name = result.string(forColumn: "name")
            books.append(book)
        }
        return books
    }
    
    func make(wordBy result: FMResultSet) -> Word {
        let word = Word()
        word.id = Int(result.int(forColumn: "id"))
        word.book_id = Int(result.int(forColumn: "book_id"))
        word.lesson_id = Int(result.int(forColumn: "lesson_id"))
        word.number = Int(result.int(forColumn: "number"))
        word.chinese = result.string(forColumn: "chinese")
        word.english = result.string(forColumn: "english")
        word.soundmark_uk = result.string(forColumn: "soundmark_uk")
        word.soundmark_us = result.string(forColumn: "soundmark_us")
        word.audio_url_uk = result.string(forColumn: "audio_url_uk")
        word.audio_url_us = result.string(forColumn: "audio_url_us")
        word.audio_path_uk = result.string(forColumn: "audio_path_uk")
        word.audio_path_us = result.string(forColumn: "audio_path_us")
        return word
    }
    
    
}
