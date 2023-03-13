//
//  MainViewController.swift
//  单词听写
//
//  Created by 小红李 on 2023/3/12.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    
    var lessons = [Lesson]()
    let book = Book()
    
    var words = [Word]()
    var playIndex = 0
    var deadline: TimeInterval = 0
    var isPaused = false
    
    var task: DispatchWorkItem?
    
    
    lazy var englishLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textAlignment = .left
        label.textColor = UIColor(red: 220.0 / 255.0, green: 168.0 / 255.0, blue: 78.0 / 255.0, alpha: 1)
        return label
    }()
    lazy var soundmarkLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .left
        label.textColor = UIColor(red: 155.0 / 255.0, green: 157.0 / 255.0, blue: 168.0 / 255.0, alpha: 1)
        return label
    }()
    lazy var chineseLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = UIColor(red: 49.0 / 255.0, green: 51.0 / 255.0, blue: 72.0 / 255.0, alpha: 1)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    lazy var countLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.textColor = UIColor(red: 155.0 / 255.0, green: 157.0 / 255.0, blue: 168.0 / 255.0, alpha: 1)
        return label
    }()
    lazy var toolBar: UIView = {
        var toolBar = UIView()
        toolBar.backgroundColor = .purple
        return toolBar
    }()
    
    lazy var playButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.setImage(UIImage(named: "pause"), for: .selected)
        button.addTarget(self, action: #selector(onPlay(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "next"), for: .normal)
        button.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        return button
    }()
    
    lazy var previousButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "previous"), for: .normal)
        button.addTarget(self, action: #selector(onPrevious), for: .touchUpInside)
        return button
    }()
    
    lazy var hiddenButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(onHidden(sender:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //https://dict.youdao.com/dictvoice?audio=me
        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        
        
        
        view.addSubview(englishLabel)
        view.addSubview(chineseLabel)
        view.addSubview(soundmarkLabel)
        view.addSubview(countLabel)
        view.addSubview(toolBar)
        toolBar.addSubview(playButton)
        toolBar.addSubview(previousButton)
        toolBar.addSubview(nextButton)
        toolBar.addSubview(hiddenButton)
        englishLabel.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(view.snp.top).offset(100)
            make.height.equalTo(40)
        }
        soundmarkLabel.snp.makeConstraints { make in
            make.left.right.equalTo(englishLabel)
            make.top.equalTo(englishLabel.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        chineseLabel.snp.makeConstraints { make in
            make.left.right.equalTo(englishLabel)
            make.top.equalTo(soundmarkLabel.snp.bottom).offset(20)
            make.height.equalTo(50)
        }
        countLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.equalTo(20)
            make.bottom.equalTo(toolBar.snp.top).offset(-10)
        }
        toolBar.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(120)
        }
        playButton.snp.makeConstraints { make in
            make.centerX.equalTo(toolBar.snp.centerX)
            make.top.equalTo(toolBar.snp.top).offset(10)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton.snp.centerY)
            make.left.equalTo(playButton.snp.right).offset(20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        previousButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton.snp.centerY)
            make.right.equalTo(playButton.snp.left).offset(-20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        hiddenButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton.snp.centerY)
            make.right.equalTo(toolBar.snp.right).offset(-20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        loadWords()
        
        AudioPlayer.shared.delegate = self
        
        

    }
    
    @objc func onPlay(sender: UIButton) {
        guard words.count > 0 else { return }
        guard playIndex < words.count else { return }

        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            // 播放
            isPaused = false

            play(with: playIndex)

        } else {
            // 暂停
            isPaused = true
        }
        
    }
    
    @objc func onNext() {
        task?.cancel()
        
        playNext()
    }
    
    @objc func onPrevious() {
        task?.cancel()
        
        playPrevious()
    }
    
    @objc func onHidden(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        englishLabel.isHidden = sender.isSelected
        chineseLabel.isHidden = sender.isSelected
    }

    
    func loadWords() {
        guard let path = Bundle.main.url(forResource: "新概念第一册", withExtension: "txt") else { return }
        
        book.id = "001"
        book.name = "新概念第一册"
        
        

        do {
            let data = try Data(contentsOf: path)
            guard let content = String(data: data, encoding: .utf8) else { return }

            
            let arr = content.split(separator: "\n")
            var json = Array<Dictionary<String, String>>()
            
            var lesson: Lesson?
            for str in arr {

                let fullString = String(str)
                
                if fullString.isBlank {
                    continue
                }

                let RE = try NSRegularExpression(pattern: "Lesson.*\\d", options: .caseInsensitive)
                let matchs = RE.matches(in: fullString, options: .reportProgress, range: NSRange(location: 0, length: fullString.count))
                
                if matchs.count > 0 {
                    lesson = Lesson()
                    lesson!.id = fullString
                    lesson!.title = fullString
                    lessons.append(lesson!)
                    book.lessons.append(lesson!)
                } else {
                    let array = fullString.split(separator: " ")
                    var dict = [String:String]()
                    var text = ""
                    var pre = ""
                    for (index, str) in array.enumerated() {
                        let string = String(str)
                        
                        if string.isBlank {
                            continue
                        }

                        if index == 0 {
                            // 序号
                            dict["number"] = string
                        }
                        
                        if string.isWord {
                            
                            if text.isBlank {
                                text = string
                            } else if pre.isWord {
                                text = "\(text) \(string)"
                            }
                        }
                        
                        if index == array.count - 1 {
                            dict["chinese"] = string
                        }
                        
                        pre = string

                    }
                    if let soundmark = fullString.slice(from: "[", to: "]") {
                        dict["soundmark"] = "[\(soundmark)]"
                    }
                    
                    dict["english"] = text
                    let  word = Word()
                    word.soundmark = dict["soundmark"]
                    word.chinese = dict["chinese"]
                    word.english = dict["english"]
                    word.number = dict["number"]
                    word.bookid = book.id
                    word.lessonid = lesson?.id
                    lesson?.words.append(word)

                    json.append(dict)
                    self.words.append(word)

                }
                
            }
            
            
        } catch {

        }
        DBManager.shared.insert(book: book)
    }

    
    fileprivate func play(with word: Word) {
        guard let english = word.english else { return }
        guard let lessonid = word.lessonid else { return }
        guard let bookid = word.bookid else { return }
        
        let path = "/\(bookid)/\(lessonid)/"
        
        if DownloadManager.shared.exist(with: path, word: english, type: "0") != nil {
            playNext()
            return
        }
        
        DownloadManager.shared.download(with: path, word: english, type: "0") { error, name in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let filename = name else { return }
            
//            AudioPlayer.shared.url = URL(string: "https://dict.youdao.com/dictvoice?type=1&audio=good")
            AudioPlayer.shared.url = URL(fileURLWithPath: "/Users/xiaohongli/Documents/读音/\(path)/\(filename)")
            AudioPlayer.shared.play()
        }

        
        
        
        
        
        englishLabel.text = word.english
        chineseLabel.text = word.chinese
        soundmarkLabel.text = word.soundmark
    }
    
    fileprivate func play(with index: Int) {
        guard playIndex >= 0 else { return }
        guard words.count > 0 else { return }
        guard playIndex < words.count else { return }
        
        let word = words[playIndex]
        play(with: word)
        countLabel.text = "\(playIndex)/\(words.count)"
    }
    
    fileprivate func playNext() {
        playIndex += 1
        play(with: playIndex)
    }
    
    fileprivate func playPrevious() {
        playIndex -= 1
        play(with: playIndex)
    }
}

extension MainViewController: AudioPlayerDelegate {
    func playEnd(player: AudioPlayer, url: URL) {
//        guard isPaused == false else { return }
        
        task = DispatchWorkItem { [weak self] in
            self?.playNext()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: task!)
    }
}



extension StringProtocol { // for Swift 4 you need to add the constrain `where Index == String.Index`
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }

        return byWords
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
        //[a-zA-Z]+[']?[a-zA-Z]+[\\.]?
//        let regex: NSPredicate = NSPredicate(format:"SELF MATCHES %@","[a-zA-Z]+[\\.]?")
        let regex: NSPredicate = NSPredicate(format:"SELF MATCHES %@","[a-zA-Z]+[']?[a-zA-Z]+[\\.]?")
        return regex.evaluate(with: self)
    }
    
    var isBlank: Bool {
        let trimmedStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStr.isEmpty
    }
    
    
}
