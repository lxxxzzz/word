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

    var words = [Word]()
    var lessons: [Lesson]?

    private var playCount: Int = 0
    
    var playIndex = 0
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
    
    lazy var stopButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "stop"), for: .normal)
        button.addTarget(self, action: #selector(onStop), for: .touchUpInside)
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

        setupUI()

        setupAudioPlayer()
        
        if let lessons = self.lessons {
            for lesson in lessons {
                for word in lesson.words {
                    words.append(word)
                }
            }
        }
        
        let flag = prepareToPlay(with: playIndex)
        if flag {
            print("准备成功")
        } else {
            print("准备失败")
        }
        
        // 默认是隐藏的
        onHidden(sender: hiddenButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
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
        toolBar.addSubview(stopButton)
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
            make.right.equalTo(toolBar.snp.centerX).offset(-5)
            make.top.equalTo(toolBar.snp.top).offset(10)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        stopButton.snp.makeConstraints { make in
            make.left.equalTo(toolBar.snp.centerX).offset(5)
            make.top.equalTo(toolBar.snp.top).offset(10)
            make.width.height.equalTo(playButton)
        }
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton.snp.centerY)
            make.left.equalTo(stopButton.snp.right).offset(10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        previousButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton.snp.centerY)
            make.right.equalTo(playButton.snp.left).offset(-10)
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
        AudioPlayer.shared.delegate = self
    }
    
    @objc func onSettings() {
        let viewController = DictationSettingsViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        viewController.delegate = self
        viewController.typeControl.selectedSegmentIndex = APP.shared.pronunciationType
        viewController.deadlineStepper.value = APP.shared.deadline
        viewController.repeatCountStepper.value = Double(APP.shared.repeatCount)
        viewController.repeatIntervalStepper.value = APP.shared.repeatInterval
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
    
    @objc func onStop() {
        guard playButton.isSelected else { return }
        
        AudioPlayer.shared.stop()
        
        let resultViewController = DictationResultViewController()
        resultViewController.words = words
        resultViewController.endIndex = playIndex
        navigationController?.pushViewController(resultViewController, animated: true)
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
        chineseContainerView.isHidden = sender.isSelected
    }

    @objc func onList() {
        let viewController = WordListViewController()
        viewController.delegate = self
        if lessons != nil {
            viewController.lessons = lessons
        } else {
            viewController.words = words
        }
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
        
        var soundmark: String?
        if APP.shared.pronunciationType == 0 {
            soundmark = word.soundmark_us
        } else {
            soundmark = word.soundmark_uk
        }
        
        if let soundmark = soundmark {
            soundmarkLabel.text = "[\(soundmark)]"
        }

        NotificationCenter.default.post(name: PrepareToPlayNotification, object: word)
        
        guard let url = word.url else { return false }

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
    
    deinit {
        print("听写页面被释放了")
    }
}

extension WordDictationViewController: AudioPlayerDelegate {
    func playEnd(player: AudioPlayer, url: URL) {
        playCount += 1

        if playCount < APP.shared.repeatCount {
            // 继续播放
            task = DispatchWorkItem { [weak self] in
                guard let wself = self else { return }
                guard wself.playButton.isSelected else { return }
                
                player.play()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + APP.shared.repeatInterval, execute: task!)
        } else {
            // 已经播放完成，等待播放下一个单词
            playCount = 0
            
            if playIndex == words.count - 1 {
                // 播放按钮状态改变
                playButton.isSelected = false
                print("已经全部听写完毕")
                let resultViewController = DictationResultViewController()
                resultViewController.words = words
                resultViewController.endIndex = playIndex
                navigationController?.pushViewController(resultViewController, animated: true)
                return
            }
            task = DispatchWorkItem { [weak self] in
                guard let wself = self else { return }
                guard wself.playButton.isSelected else { return }
                
                wself.playNext()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + APP.shared.deadline, execute: task!)
        }
    }
}

extension WordDictationViewController: DictationSettingsViewControllerDelegate {
    func settings(value count: Int, interval: Double, deadline: Double, pronunciation: Int) {
        APP.shared.repeatCount = count
        APP.shared.repeatInterval = interval
        APP.shared.deadline = deadline
        APP.shared.pronunciationType = pronunciation
    }
}

extension WordDictationViewController: WordListViewControllerDelegate {
    func select(word: Word) {
        
        guard let index = words.firstIndex(of: word) else {
            return
        }
        
        playIndex = index
        if playButton.isSelected {
            play(index: playIndex)
        } else {
            prepareToPlay(with: playIndex)
        }
    }
}

extension Word {
    var url: URL? {
        var audio_path: String?
        if APP.shared.pronunciationType == 0 {
            audio_path = audio_path_us
        } else {
            audio_path = audio_path_uk
        }

        guard let audio_path = audio_path else {
            return nil
        }
        let localPath = "\(cachePath)\(audio_path)"
        
        if FileManager.default.fileExists(atPath: localPath) {
            return URL(fileURLWithPath: localPath)
        }
        
        return URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
    }
    
    var us_url: URL? {
        guard let audio_path = audio_path_us else {
            return nil
        }
        let localPath = "\(cachePath)\(audio_path)"
        
        if FileManager.default.fileExists(atPath: localPath) {
            return URL(fileURLWithPath: localPath)
        }
        
        return URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
    }
    
    var uk_url: URL? {
        guard let audio_path = audio_path_uk else {
            return nil
        }
        let localPath = "\(cachePath)\(audio_path)"
        
        if FileManager.default.fileExists(atPath: localPath) {
            return URL(fileURLWithPath: localPath)
        }
        
        return URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
    }
}


