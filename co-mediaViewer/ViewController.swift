//
//  ViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/22.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift
import Social
import Spring

class ViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mainWebView: UIWebView!
    let baseURL = URL(string: "http://www.co-media.jp/")
    
    // 画面に表示中の記事の情報を格納する変数
    var currentURLString = String()
    var currentTitle = String()
    var currentImageURLString = String()
    var currentArticle = FavoriteArticle()
    // すでにお気に入り済みの記事を格納する変数
    var favoriteArticlesURLString = [String]()

    var myComposeView:SLComposeViewController?
    
    @IBOutlet weak var favoriteButton: DesignableButton!
    let emptyHeartImage = UIImage(named:"empty_heart.png")!
    let coloredHeartImage = UIImage(named:"colored_heart.png")!
    var imageNum = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainWebView.delegate = self
        let urlRequest = URLRequest(url: baseURL!)
        mainWebView.loadRequest(urlRequest)
        self.view.addSubview(mainWebView)
        setupSwipeGestures()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        showIndicator()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {

        guard let realm = try? Realm() else{
            return
        }
        favoriteArticlesURLString = realm.objects(FavoriteArticle.self).value(forKey: "url") as! [String]
        
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
        
        // 表示されている記事がfavoriteListに含まれているかチェックしてfavoriteButtonのimageを設定
        if favoriteArticlesURLString.contains(currentURLString){
            imageNum = 0
            displayImage()
        } else {
            imageNum = 1
            displayImage()
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopIndicator()
    }
    
    var activityIndicator: UIActivityIndicatorView!
    func showIndicator(){
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = UIColor.white
        activityIndicator.center = mainWebView.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        activityIndicator.startAnimating()
        mainWebView.addSubview(activityIndicator)
    }
    
    func stopIndicator(){
        activityIndicator.stopAnimating()
    }
    
    @IBAction func clickAddFavoriteList(_ sender: Any) {
        // クリックに応じてボタンの色を変更させる
        // 保存済みの記事の場合はRealmDBから記事を削除、未保存の記事の場合はRealmDBに保存
        if favoriteArticlesURLString.contains(currentURLString){
            imageNum = 1
            clickedButtonAnimation()
            displayImage()
            
            // 保存済み記事をRealmDBから削除
            deleteFavoriteArticleInRealm()
        } else {
            imageNum = 0
            clickedButtonAnimation()
            displayImage()
            
            // 取得した各値をまとめてRealmDBに保存
            currentArticle.title = currentTitle
            currentArticle.url = currentURLString
            currentArticle.imageString = currentImageURLString
            
            // 記事をRealmDBに保存
            updateFavoriteArticleInRealm(article: currentArticle)
        }
    }
    
    func updateFavoriteArticleInRealm(article: FavoriteArticle){
        let updateFavoriteArticle = FavoriteArticle()
        updateFavoriteArticle.title = article.title
        updateFavoriteArticle.url = article.url
        updateFavoriteArticle.imageString = article.imageString
        
        guard let realm = try? Realm() else{
            print("can't complete realm setting.")
            return
        }

        // 現在時刻の取得
        let now = Date()
        updateFavoriteArticle.addedAt = now
    
        do {
            try realm.write {
                realm.add(updateFavoriteArticle, update: true)
            }
        } catch {
            print("catch the error on realm.write")
        }
    }
    
    func deleteFavoriteArticleInRealm(){
        guard let realm = try? Realm() else{
            print("can't complete realm setting.")
            return
        }
        let favoriteArticles:Results<FavoriteArticle>? = realm.objects(FavoriteArticle.self)
        let favoriteArticle = favoriteArticles?.filter("url == %@", currentURLString)
        if favoriteArticle != nil{
            do {
                try realm.write {
                    realm.delete(favoriteArticle!)
                }
            } catch {
                print("catch the error on realm.write")
            }
            alertByCancelFavorited()
        } else {
            print("This article is not contained in favorite list.")
        }
    }


    func displayImage(){
        let imageArray = [coloredHeartImage,emptyHeartImage]
        let selectedImage = imageArray[imageNum]
        favoriteButton.setImage(selectedImage, for: .normal)
    }
    
    func clickedButtonAnimation(){
        favoriteButton.animation = "pop"
        favoriteButton.curve = "spring"
        favoriteButton.duration = 1.0
        favoriteButton.damping = 0.1
        favoriteButton.velocity = 0.1
        favoriteButton.animate()
    }
    
    // お気に入り済み記事を削除した後にアラートを表示
    func alertByCancelFavorited(){
        let alertViewController = UIAlertController(title: "お気に入りリストから削除しました", message: "お気に入りに再度追加する場合はお気に入りボタンを押してください", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertViewController.addAction(confirmAction)
        self.present(alertViewController, animated: true, completion: nil)
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
    
    @IBAction func clickSNSBarButton(_ sender: Any) {
        
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
        let shareTitle = currentTitle
        let shareURL:URL = URL(string: currentURLString)!
        myComposeView?.setInitialText(shareTitle)
        myComposeView?.add(shareURL)
        self.present(myComposeView!, animated: true, completion: nil)
    }
    
    func shareFB(){
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let shareTitle = currentTitle
        let shareURL:URL = URL(string: currentURLString)!
        myComposeView?.setInitialText(shareTitle)
        myComposeView?.add(shareURL)
        self.present(myComposeView!, animated: true, completion: nil)
    }
    
    @IBAction func clickBackButton(_ sender: Any) {
        if self.mainWebView.canGoBack{
            self.mainWebView.goBack()
        } else {
            print("fail to go back")
        }
    }
    
    @IBAction func clickForwardButton(_ sender: Any) {
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
