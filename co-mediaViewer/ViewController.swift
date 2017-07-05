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

class ViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
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
        mainWebView.scrollView.delegate = self
        let urlRequest = URLRequest(url: baseURL!)
        mainWebView.loadRequest(urlRequest)
        self.view.addSubview(mainWebView)
        setupSwipeGestures()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
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
    
    @IBAction func clickAddFavoriteList(_ sender: Any) {
        guard let realm = try? Realm() else{
            print("can't complete realm setting.")
            return
        }
        // クリックに応じてボタンの色を変更させる
        // 保存済みの記事の場合はRealmDBから記事を削除、未保存の記事の場合はRealmDBに保存
        if favoriteArticlesURLString.contains(currentURLString){
            imageNum = 1
            clickedButtonAnimation()
            displayImage()
            let favoriteArticles:Results<FavoriteArticle>? = realm.objects(FavoriteArticle.self)
            let favoriteArticle = favoriteArticles?.filter("url == %@", currentURLString)
            print("favoriteArticle: \(favoriteArticle)")
            if favoriteArticle != nil{
                try! realm.write {
                    realm.delete(favoriteArticle!)
                }
                alertByCancelFavorited()
            } else {
                print("This article is not contained in favorite list.")
            }
        } else {
            imageNum = 0
            clickedButtonAnimation()
            displayImage()
            // 記事のidを生成
            let object = realm.objects(FavoriteArticle.self).sorted(byKeyPath: "id").last
            if object == nil{
                currentArticle.id = 1
            } else {
                currentArticle.id = (object?.id)! + 1
            }
            // 現在時刻の取得
            let now = Date()
            currentArticle.addedAt = now
            
            // 取得した各値をまとめてRealmDBに保存
            currentArticle.title = currentTitle
            currentArticle.url = currentURLString
            currentArticle.imageString = currentImageURLString
            try! realm.write {
                realm.add(currentArticle)
            }
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
    
    // スクロールでnvigationBarを隠す
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let beginingPoint = CGPoint(x: 0, y: 0)
        let currentPoint = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let frameSize = scrollView.frame
        let maxOffSet = contentSize.height - frameSize.height
        
        if currentPoint.y >= maxOffSet {
            self.navigationController?.hidesBarsOnSwipe = true
        } else if beginingPoint.y < currentPoint.y {
            self.navigationController?.hidesBarsOnSwipe = true
        } else {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.hidesBarsOnSwipe = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

