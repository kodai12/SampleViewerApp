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
    var selectedTitle = String()
    var selectedURLString = String()
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("fileURL: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        favoriteListTableView.delegate = self
        favoriteListTableView.dataSource = self
        
        loadData()
        favoriteListTableView.reloadData()
        // UIRefreshControlの設定
        refreshControl.attributedTitle = NSAttributedString(string: "refresh timeline")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        favoriteListTableView.addSubview(refreshControl)
    }
    
    func refresh(){
        loadData()
        favoriteListTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadData(){
        
        // マイグレーションの実行
        var config = Realm.Configuration(
            migrationBlock:{(migration, oldSchemaVersion) in
                if(oldSchemaVersion < 1){}
                if(oldSchemaVersion < 2){}
        })
        config.schemaVersion = 2
        Realm.Configuration.defaultConfiguration = config
        // データのロード
        let realm = try! Realm(configuration: config)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let unwrappedURLString = favoriteArticles?[indexPath.row].url, let unwrappedTitle = favoriteArticles?[indexPath.row].title{
            selectedURLString = unwrappedURLString
            selectedTitle = unwrappedTitle
        }
        performSegue(withIdentifier: "toDetail", sender: nil)
        favoriteListTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let detailVC: FavoriteDetailViewController = segue.destination as! FavoriteDetailViewController
            detailVC.detailTitle = selectedTitle
            detailVC.detailArticleURLString = selectedURLString
        }
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
