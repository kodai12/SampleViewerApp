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
    var favoriteArticles:Results<FavoriteArticle>?

    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteListTableView.delegate = self
        favoriteListTableView.dataSource = self
        
        loadData()
        
    }
    
    func loadData(){
        
        let realm = RealmModel.realm.realmTry
        favoriteArticles = realm.objects(FavoriteArticle.self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteArticles!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FavoriteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell") as! FavoriteTableViewCell
        cell.favoriteArticleCell = favoriteArticles?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let realm = RealmModel.realm.realmTry
            try! realm.write {
                realm.delete(RealmModel.realm.usersSet[indexPath.row])
            }
            favoriteListTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "delete") { (action, index) -> Void in
            let realm = RealmModel.realm.realmTry
            try! realm.write {
                realm.delete(RealmModel.realm.usersSet[indexPath.row])
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        
        return [deleteButton]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
