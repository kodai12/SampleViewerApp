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
    
    dynamic var id = Int()
    dynamic var addedAt = Date()
    dynamic var url = String()
    dynamic var title = String()
    dynamic var imageString = String()
    
}

struct RealmModel {
    
    struct realm{
        
        static var realmTry = try! Realm()
        static var realmsset = FavoriteArticle()
        static var usersSet =  RealmModel.realm.realmTry.objects(FavoriteArticle.self)
        
    }
    
}
