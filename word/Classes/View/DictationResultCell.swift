//
//  DictationResultCell.swift
//  word
//
//  Created by 小红李 on 2023/3/21.
//

import UIKit

protocol DictationResultCellDelegate: AnyObject {
    func operation(cell: DictationResultCell)
}

class DictationResultCell: UITableViewCell {
    weak var delegate: DictationResultCellDelegate?
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
    
    public lazy var operationButton: UIButton = {
        let button = UIButton()
        button.setTitle("写错", for: .normal)
        button.setTitle("写对", for: .selected)
        button.backgroundColor = .gray
        button.titleLabel?.font = UIFont.light(10)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onOperation), for: .touchUpInside)
        return button
    }()
    
    public lazy var flagLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .medium(12)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.text = "写错"
        label.layer.cornerRadius = 25
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 3
        return label
    }()
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(wordLabel)
        containerView.addSubview(chineseLabel)
        containerView.addSubview(operationButton)
        containerView.addSubview(flagLabel)
        
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

        chineseLabel.snp.makeConstraints { make in
            make.left.equalTo(wordLabel.snp.left)
            make.top.equalTo(wordLabel.snp.bottom).offset(5)
            make.right.equalTo(containerView.snp.right).offset(-10)
        }
        
        operationButton.snp.makeConstraints { make in
            make.right.equalTo(containerView.snp.right).offset(-10)
            make.centerY.equalTo(containerView.snp.centerY)
            make.width.equalTo(60)
            make.height.equalTo(25)
        }
        
        flagLabel.snp.makeConstraints { make in
            make.centerY.equalTo(containerView.snp.centerY)
            make.centerX.equalTo(containerView.snp.centerX)
            make.width.height.equalTo(flagLabel.layer.cornerRadius * 2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onOperation() {
        delegate?.operation(cell: self)
    }
}
