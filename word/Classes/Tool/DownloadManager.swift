//
//  DownloadManager.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit

class DownloadManager: NSObject {
    static let shared = DownloadManager()

    var path = "/audio"
    
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
    func find(fileWith path: String, filename: String) -> (url: URL, filename: String)? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            var findname = ""
            for file in files {
                let prefix = file.replacingOccurrences(of: file.extension, with: "")
                if prefix == filename {
                    findname = file
                    break
                }
            }
            guard findname.isEmpty == false else {
                return nil
            }
            return (URL(fileURLWithPath: "\(path)/\(findname)"), filename)
        } catch {
            print("获取文件目录失败: \(error)")
        }
        return nil
    }
    
    
    func download(with url: String, path: String, word:String, completion: ((_ error: String?, _ filePath: URL?,_ filename: String?) -> Void)?) {

        if let temp = find(fileWith: path, filename: word) {
            completion?(nil, temp.url, temp.filename)
            return
        }

        guard let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            completion?("url encoding失败", nil, nil)
            return
        }
        
        guard let taskUrl = URL(string: url) else {
            completion?("url转失败", nil, nil)
            return
        }
        
        let request = URLRequest(url: taskUrl)
        let session = URLSession(configuration: .default)
        session.downloadTask(with: request) { tempUrl, response, error in
            guard let tempUrl = tempUrl, error == nil else {
                print("文件下载失败")
                completion?("文件下载失败", nil, nil)
                return
            }

            guard let servername = response?.suggestedFilename else { return }
            let filename = "\(word)\(servername.extension)"
            var destinationPath = URL(fileURLWithPath: path)

            // 检查目录是否存在
            do {
                if !FileManager.default.fileExists(atPath: destinationPath.path) {
                    try FileManager.default.createDirectory(at: destinationPath, withIntermediateDirectories: true, attributes: nil)
                }
            } catch let error {
                print(error)
                completion?("文件夹目录创建失败", nil, nil)
            }
            destinationPath = destinationPath.appendingPathComponent(filename)
            do {
                // 文件移动至document
                try FileManager.default.copyItem(atPath: tempUrl.path, toPath: destinationPath.path)
                // main
                DispatchQueue.main.async {
                    completion?(nil, destinationPath, filename)
                }
            } catch let error {
                print(error)
                completion?("文件移动失败", nil, nil)
            }
        }.resume()
    }

    
    func download(with path: String, word:String, type: String, completion: ((_ error: String?, _ filePath: URL?) -> Void)?) {

        print("使用有道下载。。。。。。。。。")
        // 0美  1英
        let url = "https://dict.youdao.com/dictvoice?type=\(type)&audio=\(word)"

        guard let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else { return }
        
        guard let taskUrl = URL(string: url) else { return }
        
        let request = URLRequest(url: taskUrl)
        let session = URLSession(configuration: .default)
        session.downloadTask(with: request) { [weak self] tempUrl, response, error in
            guard let tempUrl = tempUrl, error == nil else {
                print("文件下载失败")
                completion?("文件下载失败", nil)
                return
            }

            guard let servername = response?.suggestedFilename else { return }
            let filename = "\(word)\(servername.extension)"
            var destinationPath = URL(fileURLWithPath: path)

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
            
            do {
                // 文件移动至document
                if FileManager.default.fileExists(atPath: destinationPath.path) {
                    try FileManager.default.removeItem(atPath: destinationPath.path)
                }
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
