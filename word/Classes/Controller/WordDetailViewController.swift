//
//  WordDetailViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/21.
//

import UIKit

class WordDetailViewController: UIViewController {

    var word: Word?
    var errorWords = DB.shared.allErrorWords()
    
    lazy var englishLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textAlignment = .left
        label.textColor = UIColor(red: 220.0 / 255.0, green: 168.0 / 255.0, blue: 78.0 / 255.0, alpha: 1)
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
    
    public lazy var ukAudioButton: UIButton = {
        let button = UIButton()
        button.setTitle("英", for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.backgroundColor = chineseContainerView.backgroundColor
        button.titleLabel?.font = UIFont.light(10)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onPlayUK), for: .touchUpInside)
        return button
    }()
    
    public lazy var usAudioButton: UIButton = {
        let button = UIButton()
        button.setTitle("美", for: .normal)
        button.layer.cornerRadius = ukAudioButton.layer.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = ukAudioButton.backgroundColor
        button.titleLabel?.font = ukAudioButton.titleLabel?.font
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onPlayUS), for: .touchUpInside)
        return button
    }()
    
    public lazy var networkAudioButton: UIButton = {
        let button = UIButton()
        button.setTitle("网络发音", for: .normal)
        button.layer.cornerRadius = ukAudioButton.layer.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = ukAudioButton.backgroundColor
        button.titleLabel?.font = ukAudioButton.titleLabel?.font
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onPlayNetwork), for: .touchUpInside)
        return button
    }()
    
    public lazy var errorFlagLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .light(10)
        label.numberOfLines = 0
        label.backgroundColor = .red
        label.textAlignment = .center
        label.isHidden = true
        label.text = "错"
        return label
    }()
    
    public lazy var operationButton: UIButton = {
        let button = UIButton()
        button.setTitle("加入易错", for: .normal)
        button.setTitle("移除易错", for: .selected)
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .buttonColor()
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onOperation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .bgColor()

        view.addSubview(englishLabel)
        view.addSubview(chineseContainerView)
        chineseContainerView.addSubview(chineseLabel)
        view.addSubview(usAudioButton)
        view.addSubview(ukAudioButton)
        view.addSubview(networkAudioButton)
        view.addSubview(operationButton)
        view.addSubview(errorFlagLabel)

        englishLabel.snp.makeConstraints { make in
            make.left.right.equalTo(chineseLabel)
            make.top.equalTo(view.snp.top).offset(20)
            make.height.equalTo(45)
        }
        usAudioButton.snp.makeConstraints { make in
            make.left.equalTo(englishLabel.snp.left)
            make.top.equalTo(englishLabel.snp.bottom).offset(20)
            make.height.equalTo(30)
        }
        
        ukAudioButton.snp.makeConstraints { make in
            make.top.equalTo(usAudioButton.snp.bottom).offset(10)
            make.left.height.width.equalTo(usAudioButton)
        }
        
        networkAudioButton.snp.makeConstraints { make in
            make.top.equalTo(ukAudioButton.snp.bottom).offset(10)
            make.left.height.width.equalTo(usAudioButton)
        }
        
        chineseContainerView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(networkAudioButton.snp.bottom).offset(20)
            make.height.greaterThanOrEqualTo(50)
        }
        chineseLabel.snp.makeConstraints { make in
            make.left.equalTo(chineseContainerView.snp.left).offset(10)
            make.right.equalTo(chineseContainerView.snp.right).offset(-10)
            make.top.equalTo(chineseContainerView.snp.top).offset(5)
            make.bottom.equalTo(chineseContainerView.snp.bottom).offset(-5)
        }
        
        errorFlagLabel.snp.makeConstraints { make in
            make.right.equalTo(englishLabel.snp.right)
            make.bottom.equalTo(englishLabel.snp.top)
            make.width.equalTo(20)
            make.height.equalTo(15)
        }
        
        operationButton.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.height.equalTo(operationButton.layer.cornerRadius * 2)
        }
        
        guard let word = word else {
            return
        }
        
        title = "单词详情"
        
        englishLabel.text = word.english
        chineseLabel.text = word.chinese

        if let soundmark_us = word.soundmark_us {
            usAudioButton.setTitle("    英 /\(soundmark_us)/    ", for: .normal)
        }
        if let soundmark_uk = word.soundmark_uk {
            ukAudioButton.setTitle("    美 /\(soundmark_uk)/    ", for: .normal)
        }

        if errorWords.keys.contains(word.id!) {
            errorFlagLabel.isHidden = false
            operationButton.isSelected = true
        } else {
            errorFlagLabel.isHidden = true
            operationButton.isSelected = false
        }
    }
    
    @objc func onPlayNetwork() {
        guard let word = word else {
            return
        }
        var path = "/audio"

        if APP.shared.pronunciationType == 0 {
            path.append("/us")
        } else {
            path.append("/uk")
        }
        
        let fullPath = "\(cachePath)\(path)"

        if let url = DownloadManager.shared.find(fileWith: fullPath, filename: word.english!)?.url {
            // 已经存在了，直接播放
            if AudioPlayer.shared.prepareToPlay(with: url) {
                AudioPlayer.shared.play()
            }
        } else {
            // 不存在，下载
            DownloadManager.shared.download(with: fullPath, word: word.english!, type: "0") { error, filePath, filename in
                guard let full_path = filePath else {
                    print(error)
                    print("有道下载失败[\(word.english!)]")
                    return
                }
                guard let filename = filename else { return }
                
                let dbPath = "\(path)/\(filename)"
                print(dbPath)
                
                if APP.shared.pronunciationType == 0 {
                    word.audio_path_us = dbPath
                    DB.shared.db.executeUpdate("UPDATE t_words set audio_path_us = ? where id = ?", withArgumentsIn: [dbPath, word.id!])
                } else {
                    word.audio_path_uk = dbPath
                    DB.shared.db.executeUpdate("UPDATE t_words set audio_path_uk = ? where id = ?", withArgumentsIn: [dbPath, word.id!])
                }
                if AudioPlayer.shared.prepareToPlay(with: full_path) {
                    AudioPlayer.shared.play()
                }
            }
        }
    }
    
    @objc func onPlayUK() {
        guard let word = word else {
            return
        }
        guard let url = word.uk_url else { return }
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
    
    @objc func onPlayUS() {
        guard let word = word else {
            return
        }
        guard let url = word.us_url else { return }
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
    
    @objc func onOperation(sender: UIButton) {
        guard let word = word else {
            return
        }
        
        guard let wordId = word.id else { return }
        
        if errorWords.keys.contains(wordId) {
            // 移除
            errorWords.removeValue(forKey: wordId)
            DB.shared.delete(error: wordId)
        } else {
            // 添加
            errorWords[wordId] = 1
            DB.shared.insert(error: wordId)
        }
    }

}
