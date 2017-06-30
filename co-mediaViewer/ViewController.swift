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
    let url = URL(string: "http://www.co-media.jp/")
    
    // 画面に表示中の記事の情報を格納する変数
    var currentURLString = String()
    var currentTitle = String()
    var currentImageURLString = String()
    var currentArticle = FavoriteArticle()
    // すでにお気に入り済みの記事を格納する変数
    var favoriteArticlesURLString = [String]()

    var myComposeView:SLComposeViewController?

    @IBOutlet weak var favoriteButton: DesignableButton!
    let emptyHeartImage:UIImage = UIImage(named:"empty_heart")!
    let coloredHeartImage:UIImage = UIImage(named:"colored_heart")!
    var imageNum = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlRequest = URLRequest(url: url!)
        mainWebView.loadRequest(urlRequest)
        self.view.addSubview(mainWebView)
        setupSwipeGestures()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        let realm = try! Realm()
        favoriteArticlesURLString = realm.objects(FavoriteArticle.self).value(forKey: "url") as! [String]
        if favoriteArticlesURLString.contains(currentURLString){
            favoriteButton.setImage(coloredHeartImage, for: .normal)
        } else {
            favoriteButton.setImage(emptyHeartImage, for: .normal)
        }
    }
    
    @IBAction func clickAddFavoriteList(_ sender: Any) {
        // お気に入り済みの記事だった場合アラートを表示
        guard favoriteArticlesURLString.contains(currentURLString) else {
            AlertByDuplicateFavorite()
            return
        }
        let realm = RealmModel.realm.realmTry
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
        
        // クリック時にハートボタンの色を変更
        if favoriteArticlesURLString.contains(currentURLString){
            imageNum = 0
            displayImage()
        } else {
            imageNum = 1
            displayImage()
        }
    }

    func displayImage(){
        let imageArray = [coloredHeartImage,emptyHeartImage]
        let selectedImage = imageArray[imageNum]
        favoriteButton.setImage(selectedImage, for: .normal)
    }

    func AlertByDuplicateFavorite(){
        let alertViewController = UIAlertController(title: "お気に入りできません", message: "この記事はすでにお気に入りリストに追加されています。", preferredStyle: .alert)
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
        let title = currentTitle
        myComposeView?.setInitialText(title)
        self.present(myComposeView!, animated: true, completion: nil)
    }
    
    func shareFB(){
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let title = currentTitle
        myComposeView?.setInitialText(title)
        self.present(myComposeView!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

