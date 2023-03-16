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
    
    var words = [Word]()
    
    var lessons: [Lesson]?
    
    var playIndex = 0
    var deadline: Double = 2
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
            
            prepareToPlay(with: playIndex, completion: nil)
        }

        if let deadline: Double = UserDefaults.standard.object(forKey: deadlineKey) as? Double {
            self.deadline = deadline
        }

    }
    
    func setupUI() {

        navigationItem.rightBarButtonItem = UIBarButtonItem(imageNamed: "settings", target: self, action: #selector(onSettings))
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
        toolBar.addSubview(wordListButton)
        englishLabel.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(view.snp.top).offset(50)
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
        viewController.words = words
        
        if playIndex >= 0 && words.count > 0 && playIndex < words.count {
            viewController.word = words[playIndex]
        }

        let nav = BaseNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    
    fileprivate func prepareToPlay(with index: Int, completion: ((_ success: Bool) -> Void)?) {
        guard playIndex >= 0 else {
            completion?(false)
            return
        }
        guard words.count > 0 else {
            completion?(false)
            return
        }
        guard playIndex < words.count else {
            completion?(false)
            return
        }
        
        let type = "0"
        let word = words[playIndex]

        countLabel.text = "\(playIndex + 1) / \(words.count)"
        
        guard let english = word.english else {
            completion?(false)
            return
        }
        guard let lesson = word.lesson?.title else {
            completion?(false)
            return
        }
        guard let book = word.book?.name else {
            completion?(false)
            return
        }
        
        englishLabel.text = word.english
        chineseLabel.text = word.chinese
        soundmarkLabel.text = word.soundmark
        
        let path = "/\(book)/\(lesson)/\(type)/"
        
        DownloadManager.shared.download(with: path, word: english, type: type) { error, url in
            guard error == nil else {
                completion?(false)
                print("下载失败！！！--------->\(english)")
                print(error!)
                return
            }
            
            guard let url = url else {
                completion?(false)
                return
            }

            NotificationCenter.default.post(name: PrepareToPlayNotification, object: word)
            let flag = AudioPlayer.shared.prepareToPlay(with: url)
            completion?(flag)
        }
        
    }
    
    fileprivate func playNext() {
        playIndex += 1

        prepareToPlay(with: playIndex) { success in
            guard success else {
                print("准备失败")
                return
            }
            AudioPlayer.shared.play()
        }
    }
    
    fileprivate func playPrevious() {
        playIndex -= 1
        
        prepareToPlay(with: playIndex) { success in
            guard success else {
                print("准备失败")
                return
            }
            AudioPlayer.shared.play()
        }
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
    func settings(value count: Int, interval: Double, deadline: Double) {
        AudioPlayer.shared.repeatCount = count
        AudioPlayer.shared.repeatInterval = interval
        self.deadline = deadline
        
        UserDefaults.standard.set(deadline, forKey: deadlineKey)
        UserDefaults.standard.set(count, forKey: repeatCountKey)
        UserDefaults.standard.set(interval, forKey: repeatIntervalKey)
        UserDefaults.standard.synchronize()
    }
}


