//
//  Parse.swift
//  word
//
//  Created by 小红李 on 2023/3/14.
//

import UIKit

class Parse: NSObject {
    static func convertDictionaryToString(dict: NSDictionary) -> String {
        var result:String = ""
        do {
            //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0))

            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                result = JSONString
            }
            
        } catch {
            result = ""
        }
        return result
    }
    
    static func parse() {
        guard let path = Bundle.main.url(forResource: "新概念第一册", withExtension: "txt") else { return }

        
        do {
            let book = NSMutableDictionary()
            book["name"] = "新概念第一册"
            let data = try Data(contentsOf: path)
            guard let content = String(data: data, encoding: .utf8) else { return }

            
            let arr = content.split(separator: "\n")
            
            let lessons = NSMutableArray()
            var lesson: NSMutableDictionary?
            var words: NSMutableArray?
            for str in arr {
                
                let fullString = String(str)
                
                if fullString.isBlank {
                    continue
                }

                let RE = try NSRegularExpression(pattern: "Lesson.*\\d", options: .caseInsensitive)
                let matchs = RE.matches(in: fullString, options: .reportProgress, range: NSRange(location: 0, length: fullString.count))
                
                if matchs.count > 0 {
                    words = NSMutableArray()
                    lesson = NSMutableDictionary()
                    lesson!["title"] = fullString
                    lesson!["words"] = words
                    lessons.add(lesson!)
                } else {
                    
                    let array = fullString.split(separator: " ")
                    let word = NSMutableDictionary()
                    var text = ""
                    var pre = ""
                    for (index, str) in array.enumerated() {
                        let string = String(str)
                        
                        if string.isBlank { continue }

                        if index == 0 {
                            // 序号
                            word["number"] = string
                        }
                        
                        if string.isWord {
                            if text.isBlank {
                                text = string
                            } else if pre.isWord {
                                text = "\(text) \(string)"
                            }
                        }
                        
                        if index == array.count - 1 {
                            word["chinese"] = string
                        }
                        
                        pre = string

                    }
                    if let soundmark = fullString.slice(from: "[", to: "]") {
                        word["soundmark"] = "[\(soundmark)]"
                    }
                    
                    word["english"] = text
                    words!.add(word)
                }
                lesson!["words"] = words
            }
            
            book["lessons"] = lessons
            
            
            
            let savePath = "/Users/xiaohongli/Desktop/resources/新概念第一册.plist"
            let r = book.write(toFile: savePath, atomically: true)
            print(r)
            
//            do {
//            let json = convertDictionaryToString(dict: book)
//                try json.write(toFile: "/Users/xiaohongli/Desktop/resources/新概念第一册.json", atomically: true, encoding: .utf8)
//            } catch {
//                print(error)
//            }
            

        } catch {

        }
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                return String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func slice(from: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in

            String(self[substringFrom..<endIndex])
        }
    }
    
    var isWord: Bool {
        guard self.isBlank == false else { return false }
        let regex: NSPredicate = NSPredicate(format:"SELF MATCHES %@","[a-zA-Z]+['-]?[a-zA-Z]+[\\.]?|[a-zA-Z]+")
        return regex.evaluate(with: self)
    }
    
    var isBlank: Bool {
        let trimmedStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStr.isEmpty
    }
}

extension StringProtocol {
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }

        return byWords
    }
}
