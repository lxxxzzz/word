//
//  WordStudyViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/20.
//

import UIKit

class WordStudyViewController: UIViewController {
    
    var words: [Word]?
    var lessons: [Lesson]?
    var errorWords = DB.shared.allErrorWords()
    
    public lazy var dictationButton: UIButton = {
        let button = UIButton()
        button.setTitle("听写这些单词", for: .normal)
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .buttonColor()
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onDictation), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 100
        tableView.keyboardDismissMode = .onDrag
        tableView.register(WordStudyCell.self, forCellReuseIdentifier: "cell")
        tableView.register(WordListHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        if #available(iOS 15.0, *) {
              tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        tableView.contentInsetAdjustmentBehavior = .never

        view.addSubview(tableView)
        view.addSubview(dictationButton)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
        dictationButton.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.height.equalTo(dictationButton.layer.cornerRadius * 2)
        }
    }

    deinit {
        print("WordListViewController dealloc")
    }
    
    @objc func onBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDictation() {
        guard let start = lessons?.first else {
            print("请选择开始部分")
            return
        }
        guard let end = lessons?.last else {
            print("请选择结束部分")
            return
        }
        
        let viewController = WordDictationViewController()
        viewController.title = "Lesson \(start.number ?? 0)~Lesson\(end.number ?? 0)"
        viewController.lessons = lessons
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension WordStudyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return lessons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lessons = lessons else { return 0 }
        
        let lesson = lessons[section]
        
        return lesson.words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WordStudyCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WordStudyCell
        cell.backgroundColor = view.backgroundColor
        
        if let lessons = lessons {
            let lesson = lessons[indexPath.section]
            let word = lesson.words[indexPath.row]

            if let uk_soundmark = word.soundmark_uk {
                cell.ukSoundmarkLabel.text = "[\(uk_soundmark)]"
            } else {
                cell.ukSoundmarkLabel.text = ""
            }
            
            if let us_soundmark = word.soundmark_us {
                cell.usSoundmarkLabel.text = "[\(us_soundmark)]"
            } else {
                cell.usSoundmarkLabel.text = ""
            }
            
            if errorWords.contains(word.id!) {
                cell.errorFlagLabel.isHidden = false
                cell.operationButton.isSelected = true
            } else {
                cell.errorFlagLabel.isHidden = true
                cell.operationButton.isSelected = false
            }
            
            cell.wordLabel.text = word.english
            cell.chineseLabel.text = word.chinese
        }

        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView: WordListHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as! WordListHeaderView
        if let lessons = lessons {
            let lesson = lessons[section]
            
            headerView.titleLabel.text = "Lesson \(lesson.number ?? 1)"
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lessons = lessons else { return }
        
        let lesson = lessons[indexPath.section]
        let word = lesson.words[indexPath.row]

        let viewController = WordDetailViewController()
        viewController.word = word
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension WordStudyViewController: WordStudyCellDelegate {
    func operation(cell: WordStudyCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        guard let lessons = lessons else { return }
        
        let lesson = lessons[indexPath.section]
        let word = lesson.words[indexPath.row]
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

        tableView.reloadData()
    }
    
    func playUSAudio(cell: WordStudyCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        guard let lessons = lessons else { return }
        
        let lesson = lessons[indexPath.section]
        guard let audio_path = lesson.words[indexPath.row].audio_path_us else { return }
        
        let url = URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
    
    func playUKAudio(cell: WordStudyCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        guard let lessons = lessons else { return }
        
        let lesson = lessons[indexPath.section]
        guard let audio_path = lesson.words[indexPath.row].audio_path_uk else { return }
        
        let url = URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
}
