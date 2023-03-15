//
//  SelectViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit

class SelectViewController: UIViewController {

    var data: [Lesson]?
    var startLesson: Lesson?
    var selectHandler: ((_ startLesson: Lesson, _ endLesson: Lesson) -> Void)?
    
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
        
        title = "选择"
        let button = UIButton()
        button.setImage(UIImage(named: "back"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
    }

    deinit {
        print("SelectViewController dealloc")
    }
    
    @objc func onBack() {
        dismiss(animated: true, completion: nil)
    }
}

extension SelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if let data = data {
            let lesson = data[indexPath.row]
            cell.textLabel?.text = lesson.title
            cell.textLabel?.textColor = .white
        }
        cell.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = data else { return }
        let lesson = data[indexPath.row]
        
        if startLesson == nil {
            // 选择开始
            startLesson = lesson
        } else {
            selectHandler?(startLesson!, lesson)
            startLesson = nil
            dismiss(animated: true, completion: nil)
        }
    }
}
