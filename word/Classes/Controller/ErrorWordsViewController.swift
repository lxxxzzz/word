//
//  ErrorWordsViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/20.
//

import UIKit

class ErrorWordsViewController: UIViewController {
    
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
        
        let errorWords = DB.shared.allErrorWords()
        let wordIds: [Int] = errorWords.keys.sorted()
        words = DB.shared.get(wordsBy: wordIds)
        title = "错词本"
    }

    deinit {
        print("ErrorWordsViewController dealloc")
    }
    
    @objc func onBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDictation() {
        guard let words = words else { return }
        guard words.count > 0 else { return }
        
        let viewController = WordDictationViewController()
        viewController.words = words
        viewController.title = "错词本"
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension ErrorWordsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WordStudyCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WordStudyCell
        cell.backgroundColor = view.backgroundColor
        
        if let word = words?[indexPath.row] {

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
            
            if let count = errorWords[word.id!] {
                cell.errorFlagLabel.isHidden = false
                cell.operationButton.isSelected = true
                cell.errorFlagLabel.text = "写错\(count)次"
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lessons = lessons else { return }
        
        let lesson = lessons[indexPath.section]
        let word = lesson.words[indexPath.row]
        var audio_path: String?
        if APP.shared.pronunciationType == 0 {
            audio_path = word.audio_path_us
        } else {
            audio_path = word.audio_path_uk
        }
        
        guard let audio_path = audio_path else { return }
        
        let url = URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
        AudioPlayer.shared.prepareToPlay(with: url)
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }

}

extension ErrorWordsViewController: WordStudyCellDelegate {
    func operation(cell: WordStudyCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        guard let wordId = words?[indexPath.row].id else { return }
        
        words?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        DB.shared.delete(error: wordId)
    }
    
    func playUSAudio(cell: WordStudyCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        guard let audio_path = words?[indexPath.row].audio_path_us else { return }
        
        let url = URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
    
    func playUKAudio(cell: WordStudyCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        guard let audio_path = words?[indexPath.row].audio_path_uk else { return }
        
        let url = URL(fileURLWithPath: "\(bundlePath)/audio/\(audio_path)")
        AudioPlayer.shared.prepareToPlay(with: url)
        if AudioPlayer.shared.prepareToPlay(with: url) {
            AudioPlayer.shared.play()
        }
    }
}

extension Array {
    func uniqued<H: Hashable>(_ filter: (Element) -> H) -> [Element] {
        var result = [Element]()
        var map = [H: Element]()
        for ele in self {
            let key = filter(ele)
            if map[key] == nil {
                map[key] = ele
                result.append(ele)
            }
        }
        return result
    }
}
