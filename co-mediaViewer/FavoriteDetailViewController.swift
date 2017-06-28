//
//  FavoriteDetailViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/27.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import WebKit

class FavoriteDetailViewController: UIViewController, WKUIDelegate {

    var detailWebView: WKWebView!
    var detailArticleURLString = String()
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        detailWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        detailWebView.uiDelegate = self
        view = detailWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("detailArticleURL is \(detailArticleURLString)")
        let detailURL = URL(string: (detailArticleURLString))
        let urlRequest = URLRequest(url: detailURL!)
        detailWebView.load(urlRequest)
        setupSwipeGestures()
    }
    
    func setupSwipeGestures(){
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self.detailWebView, action: #selector(FavoriteDetailViewController.goBack))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.right
        self.detailWebView.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self.detailWebView, action: #selector(FavoriteDetailViewController.goFoward))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.left
        self.detailWebView.addGestureRecognizer(gestureToLeft)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
