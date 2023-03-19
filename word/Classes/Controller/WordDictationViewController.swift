//
//  WordDictationViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/15.
//

import UIKit
import SnapKit

let PrepareToPlayNotification = NSNotification.Name(rawValue: "PrepareToPlayNotification")

class WordDictationViewController: UIViewController {
    
    let repeatCountKey = "__repeat_count_cache_key__"
    let repeatIntervalKey = "__repeat_interval_cache_key__"
    let deadlineKey = "__deadline_cache_key__"
    let pronunciationKey = "__pronunciation_cache_key__"
    
    private var words = [Word]()
    
    var lessons: [Lesson]?
    
    var playIndex = 0
    var deadline: Double = 2
    var pronunciation: Int = 0
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
    
    lazy var chineseContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 49.0 / 255.0, green: 51.0 / 255.0, blue: 72.0 / 255.0, alpha: 1)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var chineseLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    lazy var countLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
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
        button.setImage(UIImage(named: "eye_hidden"), for: .normal)
        button.setImage(UIImage(named: "eye_show"), for: .selected)
        button.addTarget(self, action: #selector(onHidden(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var wordListButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "list"), for: .normal)
        button.addTarget(self, action: #selector(onList), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        
        setupUI()

        setupAudioPlayer()
        
        if let lessons = self.lessons {
            for lesson in lessons {
                for word in lesson.words {
                    words.append(word)
                }
            }
            
            let flag = prepareToPlay(with: playIndex)
            if flag {
                print("准备成功")
            } else {
                print("准备失败")
            }
        }

        if let deadline: Double = UserDefaults.standard.object(forKey: deadlineKey) as? Double {
            self.deadline = deadline
        }

        pronunciation = UserDefaults.standard.integer(forKey: pronunciationKey)
    }
    
    func setupUI() {

        navigationItem.rightBarButtonItem = UIBarButtonItem(imageNamed: "settings", target: self, action: #selector(onSettings))
        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)

        view.addSubview(englishLabel)
        view.addSubview(chineseContainerView)
        chineseContainerView.addSubview(chineseLabel)
        view.addSubview(soundmarkLabel)
        view.addSubview(countLabel)
        view.addSubview(toolBar)
        toolBar.addSubview(playButton)
        toolBar.addSubview(previousButton)
        toolBar.addSubview(nextButton)
        toolBar.addSubview(hiddenButton)
        toolBar.addSubview(wordListButton)
        englishLabel.snp.makeConstraints { make in
            make.left.right.equalTo(chineseLabel)
            make.top.equalTo(view.snp.top).offset(50)
            make.height.equalTo(45)
        }
        soundmarkLabel.snp.makeConstraints { make in
            make.left.right.equalTo(englishLabel)
            make.top.equalTo(englishLabel.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        chineseContainerView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(soundmarkLabel.snp.bottom).offset(20)
            make.height.greaterThanOrEqualTo(50)
        }
        chineseLabel.snp.makeConstraints { make in
            make.left.equalTo(chineseContainerView.snp.left).offset(10)
            make.right.equalTo(chineseContainerView.snp.right).offset(-10)
            make.top.equalTo(chineseContainerView.snp.top).offset(5)
            make.bottom.equalTo(chineseContainerView.snp.bottom).offset(-5)
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
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        wordListButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton.snp.centerY)
            make.left.equalTo(toolBar.snp.left).offset(20)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
    }
    
    func setupAudioPlayer() {
        let repeatCount: Int = UserDefaults.standard.integer(forKey: repeatCountKey)
        if repeatCount > 0 {
            AudioPlayer.shared.repeatCount = repeatCount
        }

        if let interval: Double = UserDefaults.standard.object(forKey: repeatIntervalKey) as? Double {
            AudioPlayer.shared.repeatInterval = interval
        }
    
        AudioPlayer.shared.delegate = self
    }
    
    @objc func onSettings() {
        let viewController = DictationSettingsViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.delegate = self
        viewController.typeControl.selectedSegmentIndex = pronunciation
        viewController.deadlineStepper.value = deadline
        viewController.repeatCountStepper.value = Double(AudioPlayer.shared.repeatCount)
        viewController.repeatIntervalStepper.value = AudioPlayer.shared.repeatInterval
        present(viewController, animated: false, completion: nil)
    }
    
    @objc func onPlay(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            // 播放
            AudioPlayer.shared.play()
        } else {
            // 暂停
            AudioPlayer.shared.pause()
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

    @objc func onList() {
        let viewController = WordListViewController()
        viewController.delegate = self
        viewController.lessons = lessons
        if playIndex >= 0 && words.count > 0 && playIndex < words.count {
            viewController.word = words[playIndex]
        }

        let nav = BaseNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @discardableResult
    fileprivate func prepareToPlay(with index: Int) -> Bool {
        guard playIndex >= 0 else {
            return false
        }
        guard words.count > 0 else {
            return false
        }
        guard playIndex < words.count else {
            return false
        }
        
        let word = words[playIndex]

        countLabel.text = "\(playIndex + 1) / \(words.count)"
    
        
        englishLabel.text = word.english
        chineseLabel.text = word.chinese
        
//        let uk_path = "\(path)/audio/\(word.book!.name!)/Lesson \(word.lesson!.number!)/uk"
//        let us_path = "\(path)/audio/\(word.book!.name!)/Lesson \(word.lesson!.number!)/us"
//        
//        if let us_name = DownloadManager.shared.find(fileWith: us_path, filename: word.english!)?.filename {
//            let us_full_path = "\(word.book!.name!)/Lesson \(word.lesson!.number!)/us/\(us_name)"
//            print(us_full_path)
//            DB.shared.db.executeUpdate("UPDATE t_words set audio_path_us = ? where id = ?", withArgumentsIn: [us_full_path, word.id!])
//        }
//        
//        if let uk_name = DownloadManager.shared.find(fileWith: uk_path, filename: word.english!)?.filename {
//            
//            let uk_full_path = "\(word.book!.name!)/Lesson \(word.lesson!.number!)/uk/\(uk_name)"
//            print(uk_full_path)
//            DB.shared.db.executeUpdate("UPDATE t_words set audio_path_uk = ? where id = ?", withArgumentsIn: [uk_full_path, word.id!])
//        }
//        
//        playIndex += 1
//        prepareToPlay(with: playIndex)
//        
//        return true
        var soundmark: String?
        var audio_path: String?
        if pronunciation == 0 {
            soundmark = word.soundmark_us
            audio_path = word.audio_path_us
        } else {
            soundmark = word.soundmark_uk
            audio_path = word.audio_path_uk
        }
        
        if let soundmark = soundmark {
            soundmarkLabel.text = "[\(soundmark)]"
        }
        
        guard let audio_path = audio_path else {
            return false
        }

        let url = URL(fileURLWithPath: "\(path)/audio/\(audio_path)")

        NotificationCenter.default.post(name: PrepareToPlayNotification, object: word)
        return AudioPlayer.shared.prepareToPlay(with: url)
    }
    
    fileprivate func play(index: Int) {
        if prepareToPlay(with: playIndex) {
            AudioPlayer.shared.play()
        } else {
            print("准备失败")
        }
    }
    
    fileprivate func playNext() {
        playIndex += 1

        play(index: playIndex)
    }
    
    fileprivate func playPrevious() {
        playIndex -= 1

        play(index: playIndex)
    }
}

extension WordDictationViewController: AudioPlayerDelegate {
    func playEnd(player: AudioPlayer, url: URL) {
        
        if playIndex == words.count - 1 {
            print("已经全部听写完毕")
            let resultViewController = DictationResultViewController()
            resultViewController.data = words
            navigationController?.pushViewController(resultViewController, animated: true)
            return
        }
        
        guard AudioPlayer.shared.isPaused == false else { return }
        
        task = DispatchWorkItem { [weak self] in
            self?.playNext()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: task!)
    }
}

extension WordDictationViewController: DictationSettingsViewControllerDelegate {
    func settings(value count: Int, interval: Double, deadline: Double, pronunciation: Int) {
        AudioPlayer.shared.repeatCount = count
        AudioPlayer.shared.repeatInterval = interval
        self.deadline = deadline
        self.pronunciation = pronunciation
        
        prepareToPlay(with: playIndex)
        
        UserDefaults.standard.set(deadline, forKey: deadlineKey)
        UserDefaults.standard.set(count, forKey: repeatCountKey)
        UserDefaults.standard.set(interval, forKey: repeatIntervalKey)
        UserDefaults.standard.set(pronunciation, forKey: pronunciationKey)
        UserDefaults.standard.synchronize()
    }
}

extension WordDictationViewController: WordListViewControllerDelegate {
    func select(word: Word) {
        
        if let index = words.firstIndex(of: word) {
            playIndex = index
            play(index: playIndex)
        }
        
    }
}

/**
 let path = "/Users/xiaohongli/Desktop/mp3"
 let uk_path = "\(word.book!.name!)/Lesson \(word.lesson!.number!)/uk"
 let us_path = "\(word.book!.name!)/Lesson \(word.lesson!.number!)/us"
 
 let full_uk_path = "\(path)/\(uk_path)"
 let full_us_path = "\(path)/\(us_path)"
 
 let group = DispatchGroup()
 group.enter()
 
 var success = false
 
 if word.english == "Wayle" {
     print("error")
 }
 
 DownloadManager.shared.download(with: word.audio_url_uk!, path: full_uk_path, word: word.english!) { error, filePath, filename in
     
     
     
     if error == nil {
         let flag = AudioPlayer.shared.prepareToPlay(with: filePath!)
         
         if flag == false {
             print("\(word.english) uk 播放失败 \(word.audio_url_uk!)")
             DownloadManager.shared.download(with: full_uk_path, word: word.english!, type: "1") { error, filePath in
                 if error != nil {
                     print("uk下载失败\(word.english)")
                 } else {
                     print("有道下载成功")
                     success = true
                     DB.shared.db.executeUpdate("UPDATE t_words set audio_path_uk = ? where id = ?", withArgumentsIn: ["\(uk_path)/\(filename)", word.id])
                     
                 }
                 group.leave()
             }
         } else {
             success = true
             DB.shared.db.executeUpdate("UPDATE t_words set audio_path_uk = ? where id = ?", withArgumentsIn: ["\(uk_path)/\(filename)", word.id])
             group.leave()
         }
     } else {
         DownloadManager.shared.download(with: full_uk_path, word: word.english!, type: "1") { error, filePath in
             if error != nil {
                 print("uk下载失败\(word.english)")
             } else {
                 print("有道下载成功")
                 success = true
                 DB.shared.db.executeUpdate("UPDATE t_words set audio_path_uk = ? where id = ?", withArgumentsIn: ["\(uk_path)/\(filename)", word.id])
                 
             }
             group.leave()
         }
         
         
     }
     
 }
 
 group.enter()
 DownloadManager.shared.download(with: word.audio_url_us!, path: full_us_path, word: word.english!) { error, filePath, filename in
     if error == nil {
         let flag = AudioPlayer.shared.prepareToPlay(with: filePath!)
         if flag == false {
             print("\(word.english)  us 播放失败 \(word.audio_url_us!)")
             DownloadManager.shared.download(with: full_us_path, word: word.english!, type: "0") { error, filePath in
                 if error != nil {
                     print("us下载失败\(word.english)")
                 } else {
                     print("有道下载成功")
                     success = true
                     DB.shared.db.executeUpdate("UPDATE t_words set audio_path_us = ? where id = ?", withArgumentsIn: ["\(us_path)/\(filename)", word.id])
                 }
                 group.leave()
             }
         } else {
             success = true
             DB.shared.db.executeUpdate("UPDATE t_words set audio_path_us = ? where id = ?", withArgumentsIn: ["\(us_path)/\(filename)", word.id])
             group.leave()
         }
     } else {
         DownloadManager.shared.download(with: full_us_path, word: word.english!, type: "0") { error, filePath in
             if error != nil {
                 print("us下载失败\(word.english)")
             } else {
                 print("有道下载成功")
                 success = true
                 DB.shared.db.executeUpdate("UPDATE t_words set audio_path_us = ? where id = ?", withArgumentsIn: ["\(us_path)/\(filename)", word.id])
             }
             group.leave()
         }
     }
 }
 
 group.notify(queue: .main) {
     NotificationCenter.default.post(name: PrepareToPlayNotification, object: word)
     
     if success {
         self.playIndex += 1
         self.prepareToPlay(with: self.playIndex, completion: nil)
     } else {
         print("---------------")
         
     }
 }
 */

