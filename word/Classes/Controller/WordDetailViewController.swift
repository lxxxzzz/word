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
    
    public lazy var ukSoundmarkLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .light(14)
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var usSoundmarkLabel: UILabel = {
        var label = UILabel()
        label.textColor = ukSoundmarkLabel.textColor
        label.font = ukSoundmarkLabel.font
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var ukAudioButton: UIButton = {
        let button = UIButton()
        button.setTitle("英", for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .gray
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
        view.addSubview(usSoundmarkLabel)
        view.addSubview(ukAudioButton)
        view.addSubview(ukSoundmarkLabel)
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
            make.height.equalTo(20)
            make.width.equalTo(40)
        }
        usSoundmarkLabel.snp.makeConstraints { make in
            make.left.equalTo(usAudioButton.snp.right).offset(5)
            make.centerY.equalTo(usAudioButton.snp.centerY)
            make.right.equalTo(englishLabel.snp.right)
        }

        ukAudioButton.snp.makeConstraints { make in
            make.top.equalTo(usAudioButton.snp.bottom).offset(10)
            make.left.height.width.equalTo(usAudioButton)
        }
        ukSoundmarkLabel.snp.makeConstraints { make in
            make.left.equalTo(ukAudioButton.snp.right).offset(5)
            make.centerY.equalTo(ukAudioButton.snp.centerY)
            make.right.equalTo(usSoundmarkLabel.snp.right)
        }
        
        chineseContainerView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(ukAudioButton.snp.bottom).offset(20)
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
            usSoundmarkLabel.text = "[\(soundmark_us)]"
        }
        if let soundmark_uk = word.soundmark_uk {
            ukSoundmarkLabel.text = "[\(soundmark_uk)]"
        }

        if errorWords.contains(word.id!) {
            errorFlagLabel.isHidden = false
            operationButton.isSelected = true
        } else {
            errorFlagLabel.isHidden = true
            operationButton.isSelected = false
        }
    }
    
    @objc func onPlayUK() {
        guard let word = word else {
            return
        }
        
        guard let audio_path = word.audio_path_uk else { return }
        let url = URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
    
    @objc func onPlayUS() {
        guard let word = word else {
            return
        }
        
        guard let audio_path = word.audio_path_us else { return }
        let url = URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
    
    @objc func onOperation(sender: UIButton) {
        guard let word = word else {
            return
        }
        
        guard let wordId = word.id else { return }
        
        if errorWords.contains(wordId) {
            // 移除
            if let index = errorWords.firstIndex(of: wordId) {
                errorWords.remove(at: index)
                DB.shared.delete(error: wordId)
            }
            
        } else {
            // 添加
            errorWords.append(wordId)
            DB.shared.insert(error: wordId)
        }
    }

}
