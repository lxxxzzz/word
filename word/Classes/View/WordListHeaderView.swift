//
//  WordListHeaderView.swift
//  word
//
//  Created by 小红李 on 2023/3/19.
//

import UIKit

class WordListHeaderView: UITableViewHeaderFooterView {

    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .red
        return label
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.left.equalTo(contentView.snp.left).offset(20)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView.snp.left).offset(5)
            make.centerX.equalTo(containerView.snp.centerX)
            make.top.bottom.centerY.equalTo(containerView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
