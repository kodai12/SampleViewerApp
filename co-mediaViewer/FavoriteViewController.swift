//
//  FavoriteViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/23.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var favoriteListTableView: UITableView!
    var favoriteArticles = [FavoriteArticle]()
    var favoriteArticle:Results<FavoriteArticle>?

    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteListTableView.delegate = self
        favoriteListTableView.dataSource = self
        
        loadData()
        print("favoriteArticle is \(favoriteArticle!)")
    }
    
    func loadData(){
        
        let realm = RealmModel.realm.realmTry
        favoriteArticle = realm.objects(FavoriteArticle.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FavoriteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell") as! FavoriteTableViewCell
        cell.realmSetting(indexPath: indexPath)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
