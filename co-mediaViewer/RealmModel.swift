//
//  RealmModel.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/25.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteArticle: Object {
    
    dynamic var url = String()
    dynamic var title = String()
    
}

struct RealmModel {
    
    struct realm{
        
        static var realmTry = try!Realm()
        static var realmsset = FavoriteArticle()
        static var usersSet =  RealmModel.realm.realmTry.objects(FavoriteArticle.self)
        
    }
    
}
