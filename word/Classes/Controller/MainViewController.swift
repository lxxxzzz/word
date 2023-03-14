//
//  MainViewController.swift
//  单词听写
//
//  Created by 小红李 on 2023/3/12.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    var book = Book()
    
    var words = [Word]()
    var playIndex = 0
    var deadline: TimeInterval = 2
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
        toolBar.backgroundColor = UIColor(red: 42.0 / 255.0, green: 45.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
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
    
    lazy var selectButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(onSelect), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        toolBar.addSubview(selectButton)
        englishLabel.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(view.snp.top).offset(100)
            make.height.equalTo(45)
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
        
        selectButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton.snp.centerY)
            make.left.equalTo(toolBar.snp.left).offset(20)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        loadData()

        AudioPlayer.shared.delegate = self
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "file/books/新概念第一册", withExtension: "plist") else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let books:[String: AnyObject] = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: AnyObject] else { return }

        book.name = books["name"] as? String
        guard let lessons = books["lessons"] as? Array<Dictionary<String, Any>> else { return  }
        
        for lessonDict in lessons {
            let lesson = Lesson()
            lesson.title = lessonDict["title"] as? String
            lesson.book = book
            book.lessons.append(lesson)
            if let words = lessonDict["words"] as? Array<Dictionary<String, String>> {
                for wordDict in words {
                    let word = Word()
                    word.book = book
                    word.lesson = lesson
                    word.english = wordDict["english"]
                    word.soundmark = wordDict["soundmark"]
                    word.chinese = wordDict["chinese"]
                    word.number = wordDict["number"]
                    lesson.words.append(word)
                    
                    self.words.append(word)
                }
            }
        }
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
        
        soundmarkLabel.isHidden = sender.isSelected
        englishLabel.isHidden = sender.isSelected
        chineseLabel.isHidden = sender.isSelected
    }

    @objc func onSelect() {
        let viewController = SelectViewController()
        viewController.data = book.lessons
        viewController.selectHandler = { [weak self] start, end in
            print("选择了\(start.title!)~\(end.title!)")
            guard let index1 = self?.book.lessons.firstIndex(of: start) else { return }
            guard let index2 = self?.book.lessons.firstIndex(of: end) else { return }
            
            let startIndex = min(index1, index2)
            let endIndex = max(index1, index2)
            self?.words.removeAll()
            for i in startIndex...endIndex {
                if let lesson = self?.book.lessons[i] {
                    for word in lesson.words {
                        self?.words.append(word)
                    }
                }
            }
            
            self?.playIndex = 0
        }
        present(viewController, animated: true, completion: nil)
    }

    fileprivate func play(with word: Word, type: String) {
        guard let english = word.english else { return }
        guard let lesson = word.lesson?.title else { return }
        guard let book = word.book?.name else { return }
        
        let path = "/\(book)/\(lesson)/\(type)/"

        DownloadManager.shared.download(with: path, word: english, type: type) { error, url in
            guard error == nil else {
                print("下载失败！！！--------->\(english)")
                print(error!)
                return
            }
            
            guard let url = url else { return }

            AudioPlayer.shared.play(with: url)
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
        play(with: word, type: "0")
        countLabel.text = "\(playIndex + 1)/\(words.count)"
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
        guard isPaused == false else { return }
        
        task = DispatchWorkItem { [weak self] in
            self?.playNext()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: task!)
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
