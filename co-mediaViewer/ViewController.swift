//
//  ViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/22.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mainWebView: UIWebView!
    let url = URL(string: "http://www.co-media.jp/")
    
    var currentURLString = String()
    var currentTitle = String()
    var currentImageURLString = String()
    
    var currentArticle = FavoriteArticle()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlRequest = URLRequest(url: url!)
        mainWebView.loadRequest(urlRequest)
        self.view.addSubview(mainWebView)
        setupSwipeGestures()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    @IBAction func clickAddFavoriteList(_ sender: Any) {
        let realm = RealmModel.realm.realmTry
        let object = realm.objects(FavoriteArticle.self).sorted(byKeyPath: "id").last
        if object == nil{
            currentArticle.id = 1
        } else {
            currentArticle.id = (object?.id)! + 1
        }
        // 現在時刻の取得
        let now = Date()
        currentArticle.addedAt = now
        
        // webViewからタイトル、URL、投稿日、イメージを取得
        if let unwrappedURLString = mainWebView.request?.url?.absoluteString{
            currentURLString = unwrappedURLString
        }
        if let unwrappedTitle = mainWebView.stringByEvaluatingJavaScript(from: "document.title"){
            currentTitle = unwrappedTitle
        }
        
        if let unwrappedImageURLString = mainWebView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('meta')[7].getAttribute('content')"){
            currentImageURLString = unwrappedImageURLString
        }

        // 取得した各値をまとめてRealmDBに保存
        currentArticle.title = currentTitle
        currentArticle.url = currentURLString
        currentArticle.imageString = currentImageURLString
        
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

