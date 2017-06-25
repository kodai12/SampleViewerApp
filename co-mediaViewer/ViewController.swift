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

class ViewController: UIViewController, WKUIDelegate {
    
    var mainWebView: WKWebView!
    let url = URL(string: "http://www.co-media.jp/")
    
    var currentURL: URL?
    var currentTitle: String?
    
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
    }
    
    @IBAction func clickAddFavoriteList(_ sender: Any) {
     
        // webViewからタイトル、URL、投稿日、イメージを取得
        currentURL = mainWebView.url
        currentTitle = mainWebView.title
        
        // 取得した各値をまとめてRealmに保存
        if currentTitle != nil && currentURL != nil{
            currentArticle.title = currentTitle!
            currentArticle.url = String(describing: currentURL)
        }
        let realm = RealmModel.realm.realmTry
        try! realm.write {
            realm.add(currentArticle)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

