//
//  DownloadManager.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit

class DownloadManager: NSObject {
    static let shared = DownloadManager()
    
//    var path = "/Users/xiaohongli/Desktop/word/读音"
    
    var path: String {
        guard let path = Bundle.main.path(forResource: "resources/audio", ofType: nil) else { return "" }
        return path
    }
    
    private override init() {}
    
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

extension DownloadManager {
    func exist(with path: String, word: String, type: String) -> URL? {
        do {
            let fullPath = "\(self.path)\(path)"
            
            guard FileManager.default.fileExists(atPath: fullPath) else { return nil }
            
            let files = try FileManager.default.contentsOfDirectory(atPath: fullPath)
            var name = ""
            for filename in files {
                let firstname = filename.replacingOccurrences(of: filename.extension, with: "")
                if firstname == word {
                    name = filename
                    break
                }
            }
            guard name.isEmpty == false else {
                return nil
            }
            return URL(fileURLWithPath: "\(self.path)\(path)\(name)")
        } catch let error as NSError {
            print("获取文件目录失败: \(error)")
        }
        
        return nil
    }

    
    func download(with path: String, word:String, type: String, completion: ((_ error: String?, _ filePath: URL?) -> Void)?) {

        if let url = exist(with: path, word: word, type: type) {
            completion?(nil, url)
            return
        }
        
        // 不存在，下载
        // 0美  1英
        let url = "https://dict.youdao.com/dictvoice?type=\(type)&audio=\(word)"

        guard let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }
        
        guard let taskUrl = URL(string: url) else { return }
        
        let request = URLRequest(url: taskUrl)
        let session = URLSession(configuration: .default)
        session.downloadTask(with: request) { [weak self] tempUrl, response, error in
            guard let self = self, let tempUrl = tempUrl, error == nil else {
                print("文件下载失败")
                completion?("文件下载失败", nil)
                return
            }

            guard let servername = response?.suggestedFilename else { return }
            let filename = "\(word)\(servername.extension)"
            var destinationPath = URL(fileURLWithPath: "\(self.path)\(path)")

            // 检查目录是否存在
            do {
                if !FileManager.default.fileExists(atPath: destinationPath.path) {
                    try FileManager.default.createDirectory(at: destinationPath, withIntermediateDirectories: true, attributes: nil)
                }
            } catch let error {
                print(error)
                completion?("文件夹目录创建失败", nil)
            }
            destinationPath = destinationPath.appendingPathComponent(filename)
            print("文件下载 document下的可保存的url:\(destinationPath)")
            do {
                // 文件移动至document
                try FileManager.default.copyItem(atPath: tempUrl.path, toPath: destinationPath.path)
                // main
                DispatchQueue.main.async {
                    completion?(nil, destinationPath)
                }
            } catch let error {
                print(error)
                completion?("文件移动失败", nil)
            }
        }.resume()
    }
    
    
    
}

extension String {
    var `extension`: String {
        if let index = self.lastIndex(of: ".") {
            return String(self[index...])
        } else {
            return ""
        }
    }
}
