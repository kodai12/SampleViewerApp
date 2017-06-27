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
        
        // 取得した各値をまとめてRealmDBに保存
        if let unwrappedTitle = currentTitle, let unwrappedURL = currentURL{
            currentArticle.title = unwrappedTitle
            currentArticle.url = String(describing: unwrappedURL)
        }
        let realm = RealmModel.realm.realmTry
        try! realm.write {
            realm.add(currentArticle)
        }
        // お気入りリストに追加後FavoriteVCに遷移
        let firstSettingTBC: firstSettingTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "firstSettingTBC") as! firstSettingTabBarController
        self.present(firstSettingTBC, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

