//
//  DictationResultViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/15.
//

import UIKit
import SnapKit

class DictationResultViewController: UIViewController {
    
    var endIndex = -1
    var words: [Word]?
    var errorWords = [Word]()
    var unwrittenWords = [Word]()
    var errorWordLibrary = DB.shared.allErrorWords()

    private lazy var tableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        tableView.register(DictationResultCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
              tableView.sectionHeaderTopPadding = 0
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        return tableView
    }()
    
    public lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setTitle("检查完成", for: .normal)
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .buttonColor()
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onCheck), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        
        tableView.contentInsetAdjustmentBehavior = .never

        view.addSubview(tableView)
        view.addSubview(checkButton)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
        checkButton.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.height.equalTo(checkButton.layer.cornerRadius * 2)
        }
        
        title = "听写结果"
    }

    deinit {
        print("DictationResultViewController dealloc")
    }
    
    @objc func onCheck() {
        guard let totalCount = words?.count else { return }
        
        let alertController = UIAlertController(title: "听写结果", message: "共听写\(totalCount)个\n写错\(errorWords.count)个\n未写\(unwrittenWords.count)个", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension DictationResultViewController: DictationResultCellDelegate {
    func operation(cell: DictationResultCell) {
        guard let data = words else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let word = data[indexPath.row]
        if !errorWords.contains(word) {
            errorWords.append(data[indexPath.row])
        } else {
            if let index = errorWords.firstIndex(of: word) {
                errorWords.remove(at: index)
            }
        }
        
        guard let wordId = word.id else { return }

        if errorWordLibrary.contains(wordId) {
            // 移除
            if let index = errorWordLibrary.firstIndex(of: wordId) {
                errorWordLibrary.remove(at: index)
                DB.shared.delete(error: wordId)
            }
        } else {
            // 添加
            errorWordLibrary.append(wordId)
            DB.shared.insert(error: wordId)
        }
        tableView.reloadData()
    }
}

extension DictationResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DictationResultCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DictationResultCell
        
        if let data = words {
            let word = data[indexPath.row]
            cell.wordLabel.text = word.english
            cell.chineseLabel.text = word.chinese
            if endIndex < indexPath.row {
                cell.flagLabel.isHidden = false
                cell.flagLabel.text = "未写"
                cell.flagLabel.textColor = .gray
                cell.flagLabel.layer.borderColor = UIColor.gray.cgColor
                cell.operationButton.isHidden = true
                unwrittenWords.append(word)
            } else if errorWords.contains(word) {
                cell.flagLabel.isHidden = false
                cell.flagLabel.text = "写错"
                cell.flagLabel.textColor = .red
                cell.flagLabel.layer.borderColor = UIColor.red.cgColor
                cell.operationButton.isSelected = true
                cell.operationButton.isHidden = false
            } else {
                cell.flagLabel.isHidden = true
                cell.flagLabel.text = nil
                cell.operationButton.isSelected = false
                cell.operationButton.isHidden = false
            }
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
