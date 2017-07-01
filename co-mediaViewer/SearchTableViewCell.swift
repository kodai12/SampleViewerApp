//
//  SearchTableViewCell.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/07/01.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var searchedWord = String()
    @IBOutlet weak var searchWordLabel: UILabel!

    func updateCellUI(){
        searchWordLabel.text = searchedWord
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
