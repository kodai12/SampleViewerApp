//
//  FavoriteDetailViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/27.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import Social

class FavoriteDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var detailWebView: UIWebView!
    var detailTitle = String()
    var detailArticleURLString = String()
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var myComposeView:SLComposeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string: detailArticleURLString)
        let urlRequest = URLRequest(url: url! as URL)
        detailWebView.loadRequest(urlRequest)
        self.view.addSubview(detailWebView)
        setupSwipeGestures()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // navigationBarの生成
        let navBar = UINavigationBar(frame: CGRect(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        navBar.barTintColor = UIColor(red:0.05, green:0.50, blue:0.32, alpha:0.8)
        self.view.addSubview(navBar)
        // barButtonItemの生成
        let shareButton = UIButton(frame: CGRect(x:0,y:0,width:100,height:50))
        shareButton.tintColor = UIColor(red:0.06, green:0.47, blue:0.12, alpha:1.0)
        shareButton.layer.masksToBounds = true
        shareButton.setTitle("Share", for: .normal)
        shareButton.addTarget(self, action: #selector(FavoriteDetailViewController.clickShareButton(_:)), for: .touchUpInside)
        let backButton = UIButton(frame: CGRect(x:0,y:0,width:100,height:50))
        backButton.tintColor = UIColor(red:0.06, green:0.47, blue:0.12, alpha:1.0)
        backButton.layer.masksToBounds = true
        backButton.setTitle("＜ Back", for: .normal)
        backButton.addTarget(self, action: #selector(FavoriteDetailViewController.clickBackButton(_:)), for: .touchUpInside)
        let shareBarButtonItem = UIBarButtonItem(customView: shareButton)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = shareBarButtonItem
        navItem.leftBarButtonItem = backBarButtonItem
        navBar.setItems([navItem], animated: false)
    }
    
    func setupSwipeGestures(){
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self, action: #selector(FavoriteDetailViewController.goBack))
        gestureToRight.direction = .right
        self.view.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self, action: #selector(FavoriteDetailViewController.goFoward))
        gestureToLeft.direction = .left
        self.view.addGestureRecognizer(gestureToLeft)
    }
    
    func goBack(){
        if self.detailWebView.canGoBack{
            self.detailWebView.goBack()
        } else {
            print("fail to go back")
        }
    }
    
    func goFoward(){
        if self.detailWebView.canGoForward{
            self.detailWebView.goForward()
        } else {
            print("fail to go foward")
        }
    }
    
    @IBAction func clickBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickShareButton(_ sender: Any) {
        
        let alertViewController = UIAlertController(title: "シェアしますか？", message: "", preferredStyle: .actionSheet)
        let twitterShareAction = UIAlertAction(title: "Twitter", style: .default, handler:{ (action:UIAlertAction) -> Void in
            self.shareTwitter()
        })
        let FBShareAction = UIAlertAction(title: "Facebook", style: .default, handler:{ (action:UIAlertAction) -> Void in
            self.shareFB()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alertViewController.addAction(twitterShareAction)
        alertViewController.addAction(FBShareAction)
        alertViewController.addAction(cancelAction)
        self.present(alertViewController, animated: true, completion: nil)
        
    }
    
    func shareTwitter(){
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        let shareTitle = detailTitle
        let shareURL:URL = URL(string: detailArticleURLString)!
        myComposeView?.setInitialText(shareTitle)
        myComposeView?.add(shareURL)
        self.present(myComposeView!, animated: true, completion: nil)
    }
    
    func shareFB(){
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let shareTitle = detailTitle
        let shareURL:URL = URL(string: detailArticleURLString)!
        myComposeView?.setInitialText(shareTitle)
        myComposeView?.add(shareURL)
        self.present(myComposeView!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
