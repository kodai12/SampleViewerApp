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
    
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var favoriteArticleCell: FavoriteArticle?{
        didSet{
            realmSetting()
        }
    }
    
    func realmSetting(){
        
        if let unwrappedCell = favoriteArticleCell{
            url.text = unwrappedCell.url
            title.text = unwrappedCell.title
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
