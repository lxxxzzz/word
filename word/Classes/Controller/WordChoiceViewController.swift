//
//  WordChoiceViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/16.
//

import UIKit

class WordChoiceViewController: UIViewController {
    
    var book: Book!
    var words = [Word]()

    var startLesson: Lesson?
    var endLesson: Lesson?
    var lessons = [Lesson]()
    
    public lazy var dictationButton: UIButton = {
        let button = UIButton()
        button.setTitle("开始听写(已选：0个)", for: .normal)
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .buttonColor()
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onDictation), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 64
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(WordChoiceCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
              tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        if let book = book, book.lessons.count == 0 {
            book.lessons = DB.shared.allLessons(with: book)
        }
    }

    deinit {
        print("WordChoiceViewController dealloc")
    }
    
    func setupUI() {
        title = "选择要听写的单词"

        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        view.addSubview(tableView)
        view.addSubview(dictationButton)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(dictationButton.snp.top).offset(-10)
        }
        dictationButton.snp.makeConstraints { make in
            make.height.equalTo(dictationButton.layer.cornerRadius * 2)
            make.bottom.equalTo(view.snp.bottom).offset(-40)
            make.left.equalTo(view.snp.left).offset(30)
            make.right.equalTo(view.snp.right).offset(-30)
        }
    }

    func getChoiceIndex() ->(startIndex: Int?, endIndex: Int?) {
        
        var index1: Int?
        var index2: Int?
        
        if let start = startLesson {
            index1 = book.lessons.firstIndex(of: start)
        }
        
        if let end = endLesson {
            index2 = book.lessons.firstIndex(of: end)
        }

        if let startIndex = index1,let endIndex = index2 {
            return (min(startIndex, endIndex), max(startIndex, endIndex))
        } else {
            return (index1, index2)
        }
    }
    
    @objc func onBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDictation() {
        guard let start = startLesson else {
            print("请选择开始部分")
            return
        }
        guard let end = endLesson else {
            print("请选择结束部分")
            return
        }
        
        let viewController = WordDictationViewController()
        viewController.title = "Lesson \(start.number ?? 0)~Lesson\(end.number ?? 0)"
        viewController.lessons = lessons
        navigationController?.pushViewController(viewController, animated: true)
        
        startLesson = nil
        endLesson = nil
        dictationButton.setTitle("开始听写(已选：0个)", for: .normal)
        lessons.removeAll()
        tableView.reloadData()
    }
}

extension WordChoiceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book.lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WordChoiceCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WordChoiceCell
        
        
        let lesson = book.lessons[indexPath.row]
        
        let index = getChoiceIndex()
        
        if index.endIndex == indexPath.row {
            cell.type = .end
        } else if index.startIndex == indexPath.row {
            cell.type = .start
        } else if let startIndex = index.startIndex, let endIndex = index.endIndex {
            if indexPath.row >= startIndex && indexPath.row <= endIndex && startIndex != endIndex {
                cell.type = .selected
            } else {
                
                cell.type = .unselected
            }
        } else {
            cell.type = .unselected
        }
        
        if endLesson == nil {
            cell.choice = false
        } else {
            cell.choice = true
        }

        cell.textLabel?.text = "Lesson \(lesson.number ?? 0) \(lesson.name ?? "") \(lesson.name_cn ?? "")"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lesson = book.lessons[indexPath.row]
        
        if endLesson != nil {
            lessons.removeAll()
            startLesson = nil
            endLesson = nil
        }
        
        if startLesson == nil {
            // 选择开始
            startLesson = lesson
            
            lessons.removeAll()
            
            dictationButton.setTitle("开始听写(已选：0个)", for: .normal)
        } else {
            endLesson = lesson

            let index = getChoiceIndex()
            
            guard let startIndex = index.startIndex, let endIndex = index.endIndex else { return  }

            var words = [Word]()
            
            for i in startIndex...endIndex {
                let lesson = book.lessons[i]
                lessons.append(lesson)
                for word in lesson.words {
                    words.append(word)
                }
            }
            
            dictationButton.setTitle("开始听写(已选：\(words.count)个)", for: .normal)
        }
        
        tableView.reloadData()
    }
    
    
    
}
