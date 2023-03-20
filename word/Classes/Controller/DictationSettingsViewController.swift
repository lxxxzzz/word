//
//  DictationSettingsViewController.swift
//  word
//
//  Created by 小红李 on 2023/3/15.
//

import UIKit

protocol DictationSettingsViewControllerDelegate: AnyObject {
    func settings(value count: Int, interval: Double, deadline: Double, pronunciation: Int)
}

class DictationSettingsViewController: UIViewController {

    weak var delegate: DictationSettingsViewControllerDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        return view
    }()
    
    lazy var repeatCountLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    lazy var repeatCountStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 5
        stepper.addTarget(self, action: #selector(onRepeatCountValueChanged(stepper:)), for: .valueChanged)
        return stepper
    }()
    
    lazy var repeatIntervalLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    lazy var repeatIntervalStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 5
        stepper.addTarget(self, action: #selector(onRepeatIntervalValueChanged(stepper:)), for: .valueChanged)
        return stepper
    }()
    
    lazy var deadlineLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var deadlineStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 5
        stepper.addTarget(self, action: #selector(onDeadlineValueChanged(stepper:)), for: .valueChanged)
        return stepper
    }()
    
    lazy var typeLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "发音类型"
        return label
    }()
    
    lazy var typeControl: UISegmentedControl = {
        var typeControl = UISegmentedControl(items: ["美式", "英式"])
        typeControl.addTarget(self, action: #selector(onTypeValueChanged(segementControl:)), for: .valueChanged)
        
        return typeControl
    }()
    
    public lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.layer.cornerRadius = 24
        button.layer.masksToBounds = true
        button.backgroundColor = .buttonColor()
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        return button
    }()
    
    public lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("确定", for: .normal)
        button.layer.cornerRadius = 24
        button.layer.borderColor = UIColor.buttonColor().cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = UIFont.light(18)
        button.setTitleColor(.buttonColor(), for: .normal)
        button.addTarget(self, action: #selector(onConfirm), for: .touchUpInside)
        return button
    }()
    
    override func loadView() {
        let view = UIControl()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        view.addTarget(self, action: #selector(onDismiss), for: .touchUpInside)
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(containerView)
        containerView.addSubview(repeatCountLabel)
        containerView.addSubview(repeatCountStepper)
        
        containerView.addSubview(repeatIntervalLabel)
        containerView.addSubview(repeatIntervalStepper)
        
        containerView.addSubview(deadlineLabel)
        containerView.addSubview(deadlineStepper)
        
        containerView.addSubview(cancelButton)
        containerView.addSubview(confirmButton)
        
        containerView.addSubview(typeLabel)
        containerView.addSubview(typeControl)

        let offset = 30
        
        containerView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(view.snp.bottom)
            make.height.equalTo(420)
        }
        
        repeatCountLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView.snp.left).offset(20)
            make.top.equalTo(containerView.snp.top).offset(40)
        }
        
        repeatCountStepper.snp.makeConstraints { make in
            make.right.equalTo(containerView.snp.right).offset(-20)
            make.centerY.equalTo(repeatCountLabel.snp.centerY)
        }
        
        repeatIntervalLabel.snp.makeConstraints { make in
            make.left.equalTo(repeatCountLabel.snp.left)
            make.top.equalTo(repeatCountLabel.snp.bottom).offset(offset)
        }
        
        repeatIntervalStepper.snp.makeConstraints { make in
            make.right.equalTo(repeatCountStepper.snp.right)
            make.centerY.equalTo(repeatIntervalLabel.snp.centerY)
        }
        
        deadlineLabel.snp.makeConstraints { make in
            make.left.equalTo(repeatIntervalLabel.snp.left)
            make.top.equalTo(repeatIntervalLabel.snp.bottom).offset(offset)
        }
        
        deadlineStepper.snp.makeConstraints { make in
            make.right.equalTo(repeatCountStepper.snp.right)
            make.centerY.equalTo(deadlineLabel.snp.centerY)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(deadlineLabel.snp.left)
            make.top.equalTo(deadlineLabel.snp.bottom).offset(offset)
        }
        
        typeControl.snp.makeConstraints { make in
            make.right.equalTo(repeatCountStepper.snp.right)
            make.centerY.equalTo(typeLabel.snp.centerY)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(cancelButton.layer.cornerRadius * 2)
            make.left.equalTo(deadlineLabel.snp.left)
            make.right.equalTo(confirmButton.snp.left).offset(-20)
            make.bottom.equalTo(containerView.snp.bottom).offset(-40)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.right.equalTo(deadlineStepper.snp.right)
            make.width.top.height.equalTo(cancelButton)
        }
        
        updateRepeatCount()
        updateRepeatInterval()
        updateDeadline()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.containerView.snp.remakeConstraints { make in
                make.left.right.equalTo(self.view)
                make.bottom.equalTo(self.view.snp.bottom)
                make.height.equalTo(420)
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maskPath = UIBezierPath.init(roundedRect: containerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = containerView.bounds
        maskLayer.path = maskPath.cgPath
        containerView.layer.mask = maskLayer
    }
    
    deinit {
        print("DictationSettingsViewController dealloc")
    }
    
    func updateRepeatCount() {
        repeatCountLabel.text = "单词播放\(Int(repeatCountStepper.value))次"
    }
    
    func updateRepeatInterval() {
        repeatIntervalLabel.text = "重复间隔\(Int(repeatIntervalStepper.value))秒"
    }
    
    func updateDeadline() {
        deadlineLabel.text = "下个单词间隔\(Int(deadlineStepper.value))秒"
    }
    
    @objc func onDismiss() {
        containerView.snp.remakeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(view.snp.bottom)
            make.height.equalTo(420)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func onConfirm() {
        delegate?.settings(value: Int(repeatCountStepper.value), interval: repeatIntervalStepper.value, deadline: deadlineStepper.value, pronunciation: typeControl.selectedSegmentIndex)
        
        onDismiss()
    }
    
    @objc func onRepeatCountValueChanged(stepper: UIStepper) {
        updateRepeatCount()
    }
    
    @objc func onRepeatIntervalValueChanged(stepper: UIStepper) {
        updateRepeatInterval()
    }
    
    @objc func onDeadlineValueChanged(stepper: UIStepper) {
        updateDeadline()
    }
    
    @objc func onTypeValueChanged(segementControl: UISegmentedControl) {
        print(segementControl.selectedSegmentIndex)
    }

}


