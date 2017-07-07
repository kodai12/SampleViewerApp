//
//  SearchedResultTableViewCell.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/07/02.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit

class SearchedResultTableViewCell: UITableViewCell {

    @IBOutlet weak var searchedImageView: UIImageView!
    @IBOutlet weak var searchedTitle: UILabel!
    @IBOutlet weak var searchedURL: UILabel!
    
    var searchedResult: FavoriteArticle?{
        didSet{
            updateCellUI()
        }
    }
    
    func updateCellUI(){
        if let unwrappedTitle = searchedResult?.title, let unwrappedURL = searchedResult?.url{
            searchedTitle.text = unwrappedTitle
            searchedURL.text = unwrappedURL
        }
        if let unwrappedImageURLString = searchedResult?.imageString{
            loadImage(imageString: unwrappedImageURLString)
        }
    }
    
    let CACHE_SEC: TimeInterval = 3 * 60 // 3分キャッシュ
    func loadImage(imageString: String){
        let req = URLRequest(url: URL(string: imageString)!,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: CACHE_SEC)
        let conf = URLSessionConfiguration.default
        let session = URLSession(configuration: conf,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: req, completionHandler: {(data, response, error) in
            if error == nil {
                let image = UIImage(data: data!)
                self.searchedImageView.image = image
            } else {
                print("AsyncImageView Error: \(error?.localizedDescription)")
            }
        })
        task.resume()
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
