//
//  SearchViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/07/01.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pastSearchedTableView: UITableView!
    
    var searchWords = [String]()
    var currentSearchWord = SearchWord()
    var pastSearchedWords: Results<SearchWord>?
    
    var SearchedArticles:Results<FavoriteArticle>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        pastSearchedTableView.delegate = self
        pastSearchedTableView.dataSource = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // navigationBarの生成
        let navBar = UINavigationBar(frame: CGRect(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        navBar.barTintColor = UIColor.lightGray
        self.view.addSubview(navBar)
        // barButtonItemの生成
        let backButton = UIButton(frame: CGRect(x:0,y:0,width:100,height:50))
        backButton.tintColor = UIColor(red:0.06, green:0.47, blue:0.12, alpha:1.0)
        backButton.layer.masksToBounds = true
        backButton.setTitle("＜ Back", for: .normal)
        backButton.addTarget(self, action: #selector(SearchedResultViewController.clickBackButton), for: .touchUpInside)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = backBarButtonItem
        navBar.setItems([navItem], animated: false)
        
        loadSearchHistory()
    }
    
    func loadSearchHistory(){
        // マイグレーションの実行
        var config = Realm.Configuration(
            migrationBlock:{(migration, oldSchemaVersion) in
                if(oldSchemaVersion < 1){}
                if(oldSchemaVersion < 2){}
                if(oldSchemaVersion < 3){}
                if(oldSchemaVersion < 4){}
                if(oldSchemaVersion < 5){}
        })
        config.schemaVersion = 5
        Realm.Configuration.defaultConfiguration = config
        
        guard let realm = try? Realm(configuration: config) else{
            return
        }
        pastSearchedWords = realm.objects(SearchWord.self).sorted(byKeyPath: "id", ascending: false)
        
    }
    
    func clickBackButton(){
        let firstSettingTBC: firstSettingTabBarController = storyboard?.instantiateViewController(withIdentifier: "firstSettingTBC") as! firstSettingTabBarController
        present(firstSettingTBC, animated: false, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchBar.isFirstResponder{
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil{
            guard let realm = try? Realm() else{
                print("fail to get realm instance")
                return
            }
            
            // idを生成
            let object = realm.objects(SearchWord.self).sorted(byKeyPath: "id").last
            if object == nil{
                currentSearchWord.id = 1
            } else {
                currentSearchWord.id = (object?.id)! + 1
            }
            // 検索日時を取得
            let now = Date()
            currentSearchWord.date = now
            // 検索ワードを取得
            searchWords = (searchBar.text?.components(separatedBy: CharacterSet.whitespaces))!
            for searchWord in searchWords{
                currentSearchWord.word = searchWord
            }
            
            do {
                try realm.write {
                    realm.add(currentSearchWord)
                }
            } catch {
                print("catch the error on realm.write")
            }
            
        } else{
            print("fail to get search text")
        }
        updateSearchedResult()
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "toSearchedResult", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchedResult"{
            let searchedResultVC: SearchedResultViewController = segue.destination as! SearchedResultViewController
            searchedResultVC.searchedResults = SearchedArticles
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSearchBar()
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.setShowsCancelButton(searchText.characters.count > 0, animated: true)
    }

    func clearSearchBar(){
        searchBar.text = ""
        self.searchBar(searchBar,textDidChange: "")
    }
    
    func updateSearchedResult(){
        guard let realm = try? Realm() else {
            print("fail to get realm instance")
            return
        }
        
        SearchedArticles = realm.objects(FavoriteArticle.self).sorted(byKeyPath: "id", ascending: false)
        for searchWord in searchWords{
            SearchedArticles = SearchedArticles?.filter("title CONTAINS[c] %@", searchWord)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pastSearchedWords == nil{
            return 0
        } else {
            return pastSearchedWords!.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "searchWordCell") as! SearchTableViewCell
        cell.searchedWord = (pastSearchedWords?[indexPath.row].word)!
        cell.updateCellUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let realm = try? Realm() else {
            return
        }
        let tempResult = realm.objects(SearchWord.self).sorted(byKeyPath: "id", ascending: false)[indexPath.row]
        print("tempResult: \(tempResult)")
        let searchWord = tempResult.word
        SearchedArticles = realm.objects(FavoriteArticle.self)
        SearchedArticles = SearchedArticles?.filter("title CONTAINS[c] %@", searchWord)
        performSegue(withIdentifier: "toSearchedResult", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
