//
//  BaseNavigationController.swift
//  word
//
//  Created by 小红李 on 2023/3/15.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowImage = UIImage()
        // 设置背景颜色
        appearance.backgroundColor = UIColor(red: 43.0 / 255.0, green: 44.0 / 255.0, blue: 64.0 / 255.0, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        // 设置按钮颜色
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = self.viewControllers.count == 1
            
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.backItem(target: target, action: #selector(onBack))
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (topViewController?.preferredStatusBarStyle)!
    }

    @objc private func onBack() {
        popViewController(animated: true)
    }
}

extension UIBarButtonItem {
    public static func backItem(target: Any?, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(imageNamed: "back", target: target, action: action)
    }
    
    convenience init(imageNamed: String, target: Any?, action: Selector) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        button.setImage(UIImage(named: imageNamed), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.init(customView: button)
    }
    
}
