//
//  MainViewController.swift
//  单词听写
//
//  Created by 小红李 on 2023/3/12.
//

import UIKit
import AVFoundation
import SnapKit

class MainViewController: UIViewController {

    fileprivate let speechSynthesizer = AVSpeechSynthesizer()
    var lessons = [Lesson]()
    
    var words = [Word]()
    var playIndex = 0
    var deadline: TimeInterval = 2
    var isPaused = false
    
    lazy var englishLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    lazy var chineseLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
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
        view.backgroundColor = .white
        
        speechSynthesizer.delegate = self
        
        view.addSubview(englishLabel)
        view.addSubview(chineseLabel)
        view.addSubview(toolBar)
        toolBar.addSubview(playButton)
        toolBar.addSubview(previousButton)
        toolBar.addSubview(nextButton)
        toolBar.addSubview(hiddenButton)
        englishLabel.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top).offset(100)
        }
        chineseLabel.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(englishLabel.snp.bottom).offset(20)
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
        
//        words.append(Word("smart"))
//        words.append(Word("hat"))
//        words.append(Word("same"))
//        words.append(Word("lovely"))
//        words.append(Word("colour"))
//        words.append(Word("green"))
//        words.append(Word("come"))
//        words.append(Word("upstairs"))

        loadWords()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        cancleSpeek()
//    }
    
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
        playNext()
    }
    
    @objc func onPrevious() {
        playPrevious()
    }
    
    @objc func onHidden(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        englishLabel.isHidden = sender.isSelected
        chineseLabel.isHidden = sender.isSelected
    }

    
    func loadWords() {
        guard let path = Bundle.main.url(forResource: "新概念第一册", withExtension: "txt") else { return }


        do {
            let data = try Data(contentsOf: path)
            guard let content = String(data: data, encoding: .utf8) else { return }

            
            let arr = content.split(separator: "\n")
            for str in arr {

                let test = String(str)
                let RE = try NSRegularExpression(pattern: "Lesson.*\\d", options: .caseInsensitive)
                let matchs = RE.matches(in: test, options: .reportProgress, range: NSRange(location: 0, length: test.count))
                var lesson: Lesson?
                if matchs.count > 0 {
                    print(test)
                    lesson = Lesson()
//                    lesson.number =
                    lesson!.title = test
                    lessons.append(lesson!)

                } else {
                    let words = test.byWords
                    var dict = [String:String]()
                    var text = ""
                    let  word = Word()
                    
                    let soundmark = test.slice(from: "[", to: "]")
                    
                    for (index, str) in words.enumerated() {
                        if index == 0 {
                            dict["number"] = String(str)
                            
                            
                        }

                        if soundmark != nil && index == 1 {
                            text.append(String(str))
                        }

                    }
                    if let s = soundmark {
                        let full = "[\(s)]"
                        dict["soundmark"] = full

                        dict["chinese"] = test.slice(from: full)
                        
                        

                    }
                    
                    dict["english"] = text
                    
                    word.soundmark = dict["soundmark"]
                    word.chinese = dict["chinese"]
                    word.english = dict["english"]
                    word.number = dict["number"]
                    lesson?.words.append(word)
                    
                    
                    self.words.append(word)
                }

//                words = lesson?.words
            }
        } catch {

        }
        
    }

    func isInt(string: String?) -> Bool {
        guard let s = string else { return false }
        
        let scan: Scanner = Scanner(string: s)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    fileprivate func play(with word: Word) {
        englishLabel.text = word.english
        chineseLabel.text = word.chinese
        
        
        guard let english = word.english else { return }
        let voice = AVSpeechSynthesisVoice(language: "en-US")
//        let voice = AVSpeechSynthesisVoice(language: "zh-CN")
        
        let utterance = AVSpeechUtterance(string: english)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.voice = voice
        utterance.volume = 1
        utterance.pitchMultiplier = 1
        speechSynthesizer.speak(utterance)
    }
    
    fileprivate func play(with index: Int) {
        guard playIndex >= 0 else { return }
        guard words.count > 0 else { return }
        guard playIndex < words.count else { return }
        
        let word = words[playIndex]
        play(with: word)
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

//MARK: AVSpeechSynthesizerDelegate
extension MainViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("开始播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("播放完成")
        guard isPaused == false else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: {
            self.playNext()
        })
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("暂停播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("继续播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("取消播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        let subStr = utterance.speechString.dropFirst(characterRange.location).description
//        let rangeStr = subStr.dropLast(subStr.count - characterRange.length).description
//        willSpeekLabel.text = rangeStr
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
}
