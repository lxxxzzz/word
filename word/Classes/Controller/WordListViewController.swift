//
//  WordListViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/16.
//

import UIKit

class WordListViewController: UIViewController {
    
    var words: [Word]?
    var word: Word?
    var isManualScroll: Bool = false
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 64
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
              tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        tableView.contentInsetAdjustmentBehavior = .never

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        title = "单词列表"
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: self, action: #selector(onBack))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(imageNamed: "arrow_down", target: self, action: #selector(onBack))
        NotificationCenter.default.addObserver(self, selector: #selector(prepareToPlay(noti:)), name: PrepareToPlayNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("WordListViewController dealloc")
    }
    
    
    @objc func onBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func prepareToPlay(noti: Notification) {
        guard let words = self.words else { return }
        guard let word = noti.object as? Word else { return }
        self.word = word
        
        tableView.reloadData()
        
        guard isManualScroll == false else { return }
        guard let index = words.firstIndex(of: word) else { return }
        if index >= 0 && index <= words.count {
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
        }
    }
}

extension WordListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = view.backgroundColor
        if let data = words {
            let word = data[indexPath.row]
            if word == self.word {
                cell.textLabel?.textColor = UIColor(red: 220.0 / 255.0, green: 168.0 / 255.0, blue: 78.0 / 255.0, alpha: 1)
            } else {
                cell.textLabel?.textColor = .white
            }
            
            cell.textLabel?.text = "\(word.english ?? "") \(word.soundmark ?? "") \(word.chinese ?? "")"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating || scrollView.isTracking {
            isManualScroll = true
        }
    }
}
