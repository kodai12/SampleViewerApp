//
//  ViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/22.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
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
        if let unwrappedURL = mainWebView.url{
            currentURL = unwrappedURL as NSURL
        }
        currentTitle = mainWebView.title!

        // 取得した各値をまとめてRealmDBに保存
        currentArticle.title = currentTitle
        currentArticle.url = String(describing: currentURL)
        currentArticle.imageString = getImageURLString()
        
        try! realm.write {
            realm.add(currentArticle)
        }
        
        // お気入りリストに追加後FavoriteVCに遷移
        let firstSettingTBC: firstSettingTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "firstSettingTBC") as! firstSettingTabBarController
        self.present(firstSettingTBC, animated: true, completion: nil)
        
    }
    
    func getImageURLString() -> String{
        var currentImageURLString = String()
        mainWebView.evaluateJavaScript("document.getElementsByTagName('meta')[7].getAttribute('content')", completionHandler: {(element,error) -> Void in
            DispatchQueue.main.async {
                currentImageURLString = element as! String
                print("passing value is completed: \(currentImageURLString)")
            }
        })
        let result = mainWebView.evaluateJavaScript("document.getElementsByTagName('meta')[7].getAttribute('content')")
        print("result: \(result)")
        print("currentImageURLString: \(currentImageURLString)")
        return currentImageURLString
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

