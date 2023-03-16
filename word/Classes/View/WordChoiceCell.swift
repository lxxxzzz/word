//
//  WordChoiceCell.swift
//  word
//
//  Created by 小红李 on 2023/3/16.
//

import UIKit

enum ChoiceType {
    case start
    case end
    case selected
    case unselected
}

class WordChoiceCell: UITableViewCell {
    
    var choice: Bool = false {
        didSet {
            if choice == false {
                lineView.isHidden = true
            } else {
                switch type {
                case .start:
                    lineView.isHidden = false
                case .end:
                    lineView.isHidden = false
                case .selected:
                    lineView.isHidden = false
                case .unselected:
                    lineView.isHidden = true
                }
            }
        }
    }
    var type: ChoiceType = .unselected {
        didSet {
            switch type {
            case .start:
                markLabel.isHidden = false
//                markLabel.text = "S"
                lineView.snp.remakeConstraints { make in
                    make.top.equalTo(markLabel.snp.bottom)
                    make.bottom.equalTo(contentView.snp.bottom)
                    make.centerX.equalTo(markLabel.snp.centerX)
                    make.width.equalTo(1)
                }
            case .end:
                markLabel.isHidden = false
//                markLabel.text = "E"
                lineView.snp.remakeConstraints { make in
                    make.top.equalTo(contentView.snp.top)
                    make.bottom.equalTo(markLabel.snp.bottom)
                    make.centerX.equalTo(markLabel.snp.centerX)
                    make.width.equalTo(1)
                }
            case .selected:
                markLabel.isHidden = true
                markLabel.text = nil
                lineView.snp.remakeConstraints { make in
                    make.top.bottom.equalTo(contentView)
                    make.centerX.equalTo(markLabel.snp.centerX)
                    make.width.equalTo(1)
                }
            case .unselected:
                markLabel.isHidden = true
                markLabel.text = nil
                lineView.snp.remakeConstraints { make in
                    make.top.bottom.equalTo(contentView)
                    make.centerX.equalTo(markLabel.snp.centerX)
                    make.width.equalTo(1)
                }
            }
        }
    }

    public lazy var contentLabel: UILabel = {
        var label = UILabel()
        
        return label
    }()
    
    public lazy var lineView: UIView = {
        var lineView = UIView()
        lineView.isHidden = true
        lineView.backgroundColor = .white
        return lineView
    }()
    
    public lazy var markLabel: UILabel = {
        var label = UILabel()
        label.backgroundColor = .white
        label.isHidden = true
        label.textAlignment = .center
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        return label
    }()
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        contentView.addSubview(contentLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(markLabel)
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(20)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.equalTo(200)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.centerX.equalTo(markLabel.snp.centerX)
            make.width.equalTo(1)
        }
        
        markLabel.snp.makeConstraints { make in
            make.right.equalTo(contentView.snp.right).offset(-20)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
