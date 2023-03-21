//
//  WordStudyCell.swift
//  word
//
//  Created by 小红李 on 2023/3/20.
//

import UIKit

protocol WordStudyCellDelegate: AnyObject {
    func playUKAudio(cell: WordStudyCell)
    func playUSAudio(cell: WordStudyCell)
    func operation(cell: WordStudyCell)
}

class WordStudyCell: UITableViewCell {

    weak var delegate: WordStudyCellDelegate?
    
    private lazy var containerView: UIView = {
        var containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .lightenBgColor()
        return containerView
    }()
    
    public lazy var wordLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .regular(18)
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var chineseLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
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
        button.backgroundColor = .gray
        button.titleLabel?.font = UIFont.light(10)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onOperation), for: .touchUpInside)
        return button
    }()
    
    public lazy var lineView: UIView = {
        var lineView = UIView()
        lineView.backgroundColor = .white
        lineView.isHidden = true
        return lineView
    }()
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(wordLabel)
        containerView.addSubview(chineseLabel)
        containerView.addSubview(ukAudioButton)
        containerView.addSubview(ukSoundmarkLabel)
        containerView.addSubview(usAudioButton)
        containerView.addSubview(usSoundmarkLabel)
        containerView.addSubview(lineView)
        containerView.addSubview(errorFlagLabel)
        containerView.addSubview(operationButton)
        
        containerView.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(5)
            make.bottom.equalTo(contentView.snp.bottom).offset(-5)
            make.top.equalTo(contentView.snp.top).offset(5)
            make.right.equalTo(contentView.snp.right).offset(-5)
        }
        
        wordLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView.snp.left).offset(10)
            make.top.equalTo(containerView.snp.top).offset(10)
            make.width.equalTo(150)
        }
        
        ukAudioButton.snp.makeConstraints { make in
            make.left.equalTo(wordLabel.snp.left)
            make.top.equalTo(wordLabel.snp.bottom).offset(5)
            make.height.equalTo(ukAudioButton.layer.cornerRadius * 2)
            make.width.equalTo(40)
        }
        
        ukSoundmarkLabel.snp.makeConstraints { make in
            make.left.equalTo(ukAudioButton.snp.right).offset(5)
            make.centerY.equalTo(ukAudioButton.snp.centerY)
            make.height.equalTo(15)
        }
        
        usAudioButton.snp.makeConstraints { make in
            make.left.equalTo(ukSoundmarkLabel.snp.right).offset(10)
            make.top.height.width.equalTo(ukAudioButton)
        }
        
        usSoundmarkLabel.snp.makeConstraints { make in
            make.left.equalTo(usAudioButton.snp.right).offset(5)
            make.centerY.equalTo(usAudioButton.snp.centerY)
            make.height.equalTo(15)
            make.right.lessThanOrEqualTo(operationButton.snp.left)
        }
        
        chineseLabel.snp.makeConstraints { make in
            make.left.equalTo(wordLabel.snp.left)
            make.top.equalTo(ukAudioButton.snp.bottom).offset(5)
            make.right.equalTo(containerView.snp.right).offset(-10)
        }
        
        errorFlagLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top)
            make.right.equalTo(containerView.snp.right).offset(-10)
            make.width.equalTo(50)
            make.height.equalTo(15)
        }
        
        operationButton.snp.makeConstraints { make in
            make.right.equalTo(containerView.snp.right).offset(-10)
            make.centerY.equalTo(usSoundmarkLabel.snp.centerY)
            make.width.equalTo(60)
            make.height.equalTo(25)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(containerView)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    @objc func onPlayUK() {
        delegate?.playUKAudio(cell: self)
    }
    
    @objc func onPlayUS() {
        delegate?.playUSAudio(cell: self)
    }
    
    @objc func onOperation() {
        delegate?.operation(cell: self)
    }
}



