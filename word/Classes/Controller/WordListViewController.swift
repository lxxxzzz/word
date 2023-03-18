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
    var lessons: [Lesson]?
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
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
        guard let lessons = self.lessons else { return }
        guard let word = noti.object as? Word else { return }
        self.word = word
        
        tableView.reloadData()
        
        guard isManualScroll == false else { return }

        var indexPath: IndexPath?
        
        for (section, lesson) in lessons.enumerated() {
            if indexPath != nil {
                break
            }
            for (row, word) in lesson.words.enumerated() {
                if self.word == word {
                    indexPath = IndexPath(row: row, section: section)
                    break
                }
            }
        }
        
        if let indexPath = indexPath {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
}

extension WordListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return lessons?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lessons = lessons else { return 0 }
        
        let lesson = lessons[section]
        
        return lesson.words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = view.backgroundColor
        
        if let lessons = lessons {
            let lesson = lessons[indexPath.section]
            let word = lesson.words[indexPath.row]
            if word == self.word {
                cell.textLabel?.textColor = UIColor(red: 220.0 / 255.0, green: 168.0 / 255.0, blue: 78.0 / 255.0, alpha: 1)
            } else {
                cell.textLabel?.textColor = .white
            }
            
            let soundmark = word.soundmark_us != nil ? "[\(word.soundmark_us!)]" : ""
            
            cell.textLabel?.text = "\(word.english ?? "") \(soundmark) \(word.chinese ?? "")"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let lessons = lessons else { return "" }
        
        let lesson = lessons[section]
        
        return "Lesson \(lesson.number ?? 1)"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") {
            return headerView
        } else {
            let label = UILabel(frame: CGRect(x: 00, y: 0, width: 100, height: 20))
            if let lessons = lessons {
                let lesson = lessons[section]
                
                label.text = "    Lesson \(lesson.number ?? 1)"
            }
//            label.textColor = UIColor(red: 220.0 / 255.0, green: 168.0 / 255.0, blue: 78.0 / 255.0, alpha: 1)
            label.textColor = .red
            return label
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating || scrollView.isTracking {
            isManualScroll = true
        }
    }
}
