//
//  ViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/22.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class ViewController: UIViewController, WKUIDelegate, UIGestureRecognizerDelegate {
    
    var mainWebView: WKWebView!
    let url = URL(string: "http://www.co-media.jp/")
    
    var currentURL = NSURL()
    var currentTitle = String()
    
    var currentArticle = FavoriteArticle()
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        mainWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        mainWebView.uiDelegate = self
        view = mainWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlRequest = URLRequest(url: url!)
        mainWebView.load(urlRequest)
        setupSwipeGestures()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    @IBAction func clickAddFavoriteList(_ sender: Any) {
        
        // webViewからタイトル、URL、投稿日、イメージを取得
        if let unwrappedURL = mainWebView.url{
            currentURL = unwrappedURL as NSURL
        }
        currentTitle = mainWebView.title!
        // 取得した各値をまとめてRealmDBに保存
        currentArticle.title = currentTitle
        currentArticle.url = String(describing: currentURL)
        let realm = RealmModel.realm.realmTry
        try! realm.write {
            realm.add(currentArticle)
        }
        // お気入りリストに追加後FavoriteVCに遷移
        let firstSettingTBC: firstSettingTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "firstSettingTBC") as! firstSettingTabBarController
        self.present(firstSettingTBC, animated: true, completion: nil)
        
    }

    func setupSwipeGestures(){
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self.mainWebView, action: #selector(ViewController.goBack))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.right
        self.mainWebView.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self.mainWebView, action: #selector(ViewController.goFoward))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.left
        self.mainWebView.addGestureRecognizer(gestureToLeft)
        
    }
    
    
    func goBack(){
        if self.mainWebView.canGoBack{
            self.mainWebView.goBack()
        } else {
            print("fail to go back")
        }
    }
    
    func goFoward(){
        if self.mainWebView.canGoForward{
            self.mainWebView.goForward()
        } else {
            print("fail to go foward")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

