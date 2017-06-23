//
//  ViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/22.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    var mainWebView: WKWebView!
    let url = URL(string: "http://www.co-media.jp/")
    
    var currentURL: URL?
    var currentTitle: String?
    var currentCreatedAt: String?
    
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
        
        print("aaa")
        currentURL = mainWebView.url
        mainWebView.evaluateJavaScript("document.getElementByClassName('article-box-title').value"){(result, error) in
            if error != nil{
                print("result is \(result)")
            }
        }
        print("currentURLString is \(currentURL)")
        print("currentTitle is \(currentTitle)")    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

