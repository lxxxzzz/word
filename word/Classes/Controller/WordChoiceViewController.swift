//
//  WordChoiceViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/16.
//

import UIKit

class WordChoiceViewController: UIViewController {
    
    var book: Book!

    var startLesson: Lesson?
    var endLesson: Lesson?
    var lessons = [Lesson]()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 49.0 / 255.0, green: 51.0 / 255.0, blue: 72.0 / 255.0, alpha: 1)
        return view
    }()
    
    public lazy var countLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "已选0个"
        return label
    }()
    
    public lazy var dictationButton: UIButton = {
        let button = UIButton()
        button.setTitle("听写", for: .normal)
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .buttonColor()
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onDictation), for: .touchUpInside)
        return button
    }()
    
    public lazy var studyButton: UIButton = {
        let button = UIButton()
        button.setTitle("学习", for: .normal)
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .buttonColor()
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onStudy), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
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
            book.lessons = DB.shared.get(lessonsBy: book.id)
        }
    }

    deinit {
        print("WordChoiceViewController dealloc")
    }
    
    func setupUI() {
        title = book.name

        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        view.addSubview(containerView)
        containerView.addSubview(countLabel)
        containerView.addSubview(dictationButton)
        containerView.addSubview(studyButton)
        view.addSubview(tableView)
        containerView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(90)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(containerView.snp.top).offset(-10)
        }
        countLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView.snp.left).offset(20)
            make.centerY.equalTo(dictationButton.snp.centerY)
            make.width.equalTo(95)
        }
        dictationButton.snp.makeConstraints { make in
            make.height.equalTo(dictationButton.layer.cornerRadius * 2)
            make.left.equalTo(countLabel.snp.right).offset(5)
            make.top.equalTo(containerView.snp.top).offset(10)
            make.right.equalTo(studyButton.snp.left).offset(-10)
        }
        studyButton.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(dictationButton)
            make.right.equalTo(containerView.snp.right).offset(-20)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "全选", style: .done, target: self, action: #selector(onSelectAll))
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
    
    func choiceFinish() {
        let index = getChoiceIndex()
        guard let startIndex = index.startIndex, let endIndex = index.endIndex else { return  }
        var count = 0
        for i in startIndex...endIndex {
            let lesson = book.lessons[i]
            lessons.append(lesson)
            let words = DB.shared.get(wordsBy: lesson.id)
            lesson.words = words
            count += words.count
        }
        countLabel.text = "已选:\(count)个"
    }
    
    @objc func onBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onStudy() {
        guard let start = startLesson else {
            print("请选择开始部分")
            return
        }
        guard let end = endLesson else {
            print("请选择结束部分")
            return
        }
        
        let viewController = WordStudyViewController()
        viewController.title = "Lesson \(start.number ?? 0)~Lesson\(end.number ?? 0)"
        viewController.lessons = lessons
        navigationController?.pushViewController(viewController, animated: true)
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
    }
    
    @objc func onSelectAll() {
        startLesson = book.lessons.first
        endLesson = book.lessons.last
        choiceFinish()
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

        cell.contentLabel.text = "Lesson \(lesson.number ?? 0) \(lesson.name ?? "")"
        cell.chineseLabel.text = lesson.name_cn
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
            countLabel.text = "已选:0个"
        } else {
            endLesson = lesson
            
            choiceFinish()
        }
        
        tableView.reloadData()
    }
}
