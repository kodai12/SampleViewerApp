//
//  FavoriteViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/06/23.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift
import HidingNavigationBar

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var favoriteListTableView: UITableView!
    
    var favoriteArticles:Results<FavoriteArticle>?
    var selectedTitle = String()
    var selectedURLString = String()
    
    let refreshControl = UIRefreshControl()
    var hidingNavBarManager: HidingNavigationBarManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteListTableView.delegate = self
        favoriteListTableView.dataSource = self
        
        loadData()
        favoriteListTableView.reloadData()
        
        // UIRefreshControlの設定
        refreshControl.attributedTitle = NSAttributedString(string: "refresh timeline")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        favoriteListTableView.addSubview(refreshControl)
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: favoriteListTableView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // viewを表示後はnavigationBarのすぐ下にcellが揃うようなUIに設定
        favoriteListTableView.contentInset = UIEdgeInsets(top: (navigationController?.navigationBar.frame.maxY)!, left: 0, bottom: 0, right: 0)
        favoriteListTableView.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height - (navigationController?.navigationBar.frame.maxY)!)
        self.view.addSubview(favoriteListTableView)
        
        
        if let tabBar = navigationController?.tabBarController?.tabBar{
            hidingNavBarManager?.manageBottomBar(tabBar)
        }
        hidingNavBarManager?.viewWillAppear(animated)
        
        loadData()
        favoriteListTableView.reloadData()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabBar = navigationController?.tabBarController?.tabBar{
            hidingNavBarManager?.manageBottomBar(tabBar)
        }
        hidingNavBarManager?.viewWillDisappear(animated)
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
                migration.enumerateObjects(ofType: FavoriteArticle.className()) { oldObject, newObject in
                    if(oldSchemaVersion < 1){}
                    
                }
        })
        config.schemaVersion = 1
        Realm.Configuration.defaultConfiguration = config
        // データのロード
        guard let realm = try? Realm(configuration: config) else{
            print("fail to get realm instance")
            return
        }
        // お気に入り追加日順でソートし、データを取り込む
        favoriteArticles = realm.objects(FavoriteArticle.self).sorted(byKeyPath: "addedAt",ascending: false)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoriteArticles != nil {
            return favoriteArticles!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FavoriteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell") as! FavoriteTableViewCell
        cell.favoriteArticleCell = favoriteArticles?[indexPath.row]
        
        if indexPath.row == 0 {
            // トップまでスクロールするとnavigationBarのすぐ下にcellが揃うようなUIに設定
            favoriteListTableView.contentInset = UIEdgeInsets(top: (navigationController?.navigationBar.frame.maxY)!, left: 0, bottom: 0, right: 0)
            self.view.addSubview(favoriteListTableView)
        } else {
            favoriteListTableView.contentMode = .scaleToFill
            self.view.addSubview(favoriteListTableView)
        }
        
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
            do {
                try realm.write {
                    realm.delete(realm.objects(FavoriteArticle.self)[indexPath.row])
                }
            } catch {
                print("catch the error on realm.write")
            }
            favoriteListTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "delete") { (action, index) -> Void in
            let realm = RealmModel.realm.realmTry
            do {
                try realm.write {
                    realm.delete(realm.objects(FavoriteArticle.self)[indexPath.row])
                }
            } catch {
                print("catch the error on realm.write")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        
        return [deleteButton]
    }

    @IBAction func clickSearchButton(_ sender: Any) {
        performSegue(withIdentifier: "toSearchVC", sender: nil)    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
