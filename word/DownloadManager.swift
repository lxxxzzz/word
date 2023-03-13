//
//  DownloadManager.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit

class DownloadManager: NSObject {
    static let shared = DownloadManager()
    
    var path = "/Users/xiaohongli/Documents/读音"
    
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
    func exist(with word: String, type: String) -> String? {
        print("-------->\(word)")
        let firstname = "\(word)-\(type)"
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: path)
            var name: String?
            for fileName in array {
                let fileFirstname = fileName.replacingOccurrences(of: fileName.extension, with: "")
                if fileFirstname == firstname {
                    name = fileName
                    break
                }
            }
            return name
        } catch let error as NSError {
            print("get file path error: \(error)")
        }
        
        return nil
    }
    
    func exist(with path: String, word: String, type: String) -> String? {
        print("-------->\(word)")
        let firstname = "\(word)-\(type)"
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: "\(self.path)/\(path)")
            var name: String?
            for fileName in array {
                let fileFirstname = fileName.replacingOccurrences(of: fileName.extension, with: "")
                if fileFirstname == firstname {
                    name = fileName
                    break
                }
            }
            return name
        } catch let error as NSError {
            print("get file path error: \(error)")
        }
        
        return nil
    }

    
    func download(with path: String, word:String, type: String, completion: ((_ error: String?, _ name: String?) -> Void)?) {
        let firstname = "\(word)-\(type)"
        
        if let name = exist(with: word, type: type) {
            completion?(nil, name)
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
            let filename = "\(firstname)\(servername.extension)"
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
            destinationPath = URL(fileURLWithPath: "\(self.path)\(path)\(filename)")
            print("文件下载 document下的可保存的url:\(destinationPath)")
            do {
                // 文件移动至document
                try FileManager.default.copyItem(atPath: tempUrl.path, toPath: destinationPath.path)
                // main
                DispatchQueue.main.async {
                    completion?(nil, filename)
                }
            } catch let error {
                print(error)
                completion?("文件移动失败", nil)
            }
        }.resume()
    }
    
    func download(with word:String, type: String, completion: ((_ error: String?, _ name: String?) -> Void)?) {
        let firstname = "\(word)-\(type)"
        
        if let name = exist(with: word, type: type) {
            completion?(nil, name)
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
            let filename = "\(firstname)\(servername.extension)"
            let destinationPath = URL(fileURLWithPath: "\(self.path)\(filename)")
            print("文件下载 document下的可保存的url:\(destinationPath)")
            do {
                // 文件移动至document
                try FileManager.default.copyItem(atPath: tempUrl.path, toPath: destinationPath.path)
                // main
                DispatchQueue.main.async {
                    completion?(nil, filename)
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
