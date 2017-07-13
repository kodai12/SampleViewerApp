//
//  RealmModel.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/27.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteArticle: Object {
    
    dynamic var id = NSUUID().uuidString
    dynamic var addedAt = Date()
    dynamic var url = String()
    dynamic var title = String()
    dynamic var imageString = String()

    override static func indexedProperties() -> [String]{
        return ["title"]
    }
    
    override static func primaryKey() -> String?{
        return "id"
    }
}

class SearchWord: Object {
    
    dynamic var id = NSUUID().uuidString
    dynamic var word = String()
    dynamic var date = Date()
    
    override static func indexedProperties() -> [String]{
        return ["word"]
    }
    
    override static func primaryKey() -> String?{
        return "id"
    }
    
}
