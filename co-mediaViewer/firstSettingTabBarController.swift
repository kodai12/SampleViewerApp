//
//  firstSettingTabBarController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/27.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit

class firstSettingTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    // タブをタップ時にtableViewのトップまでスクロール
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navVC = viewController as? UINavigationController else{
            print("fail to get navVC")
            return
        }
        guard let favVC = navVC.viewControllers.first as? FavoriteViewController else{
            print("fail to get favVC")
            return
        }
        if favVC.isViewLoaded && favVC.view.window != nil{
            favVC.favoriteListTableView.setContentOffset(CGPoint.zero, animated: true)
            print("scroll to top")
        } else {
            print("favVC is not loaded")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
