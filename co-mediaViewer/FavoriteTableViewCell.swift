//
//  FavoriteTableViewCell.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/23.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    
    var favoriteArticleCell: FavoriteArticle?{
        didSet{
            realmSetting()
        }
    }
    
    func realmSetting(){
        
        if let unwrappedCell = favoriteArticleCell{
            url.text = unwrappedCell.url
            title.text = unwrappedCell.title
            loadImage(imageString: unwrappedCell.imageString)
        }
    }
    
    let CACHE_SEC: TimeInterval = 3 * 60 //3分キャッシュ
    func loadImage(imageString: String){
        showIndicator()
        let req = URLRequest(url: URL(string: imageString)!,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: CACHE_SEC)
        let conf = URLSessionConfiguration.default
        let session = URLSession(configuration: conf,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: req, completionHandler: {(data, response, error) in
            if error == nil {
                self.stopIndicator()
                let image = UIImage(data: data!)
                self.backImageView.image = image
            } else {
                print("AsyncImageView Error: \(error?.localizedDescription)")
            }
        })
        task.resume()
    }

    var activityIndicator: UIActivityIndicatorView!
    func showIndicator(){
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = UIColor.white
        activityIndicator.center = CGPoint(x: backImageView.frame.size.width/2, y: backImageView.frame.size.height/2)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        activityIndicator.startAnimating()
        backImageView.addSubview(activityIndicator)
    }
    
    func stopIndicator(){
        activityIndicator.stopAnimating()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
