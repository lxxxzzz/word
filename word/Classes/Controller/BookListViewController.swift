//
//  BookListViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/18.
//

import UIKit

class BookListViewController: UIViewController {
    
    var data: [Book]?

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
        
        title = "书架"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "错词本", style: .done, target: self, action: #selector(onErrorWords))
        
        data = DB.shared.allBooks()
    }

    deinit {
        print("BookListViewController dealloc")
    }
    
    @objc func onErrorWords() {
        let viewController = ErrorWordsViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension BookListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = view.backgroundColor
        if let data = data {
            let book = data[indexPath.row]
            cell.textLabel?.text = "\(book.name!)"
        }
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = data else { return }
        
        let book = data[indexPath.row]
        let viewController = WordChoiceViewController()
        viewController.book = book
        navigationController?.pushViewController(viewController, animated: true)
    }

}
