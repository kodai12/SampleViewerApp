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
    var detailArticleURLString: String?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        detailWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        detailWebView.uiDelegate = self
        view = detailWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let detailURL = URL(string: (detailArticleURLString)!)
        let urlRequest = URLRequest(url: detailURL!)
        detailWebView.load(urlRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
