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
    
    var getImageURLString: String?
    var getTitle: String?
    var getURLString: String?
    
    func updateCellUI(){
        searchedTitle.text = getTitle
        searchedURL.text = getURLString
        if let unwrappedImageURLString = getImageURLString{
            let imageURL = NSURL(string: unwrappedImageURLString)
            let backImageData = NSData(contentsOf: imageURL! as URL)
            searchedImageView.image = UIImage(data: backImageData! as Data)
        }
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
