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
    @IBOutlet weak var cancelButton: UIButton!
    
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
        
        // searchBarのUIsetting
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.showsCancelButton = true
        
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
            
            updateSearchedResult()
            searchBar.resignFirstResponder()
            if SearchedArticles?.count != 0 {
                print("search result is not nil")
                do {
                    try realm.write {
                        realm.add(currentSearchWord, update: true)
                    }
                } catch {
                    print("catch the error on realm.write")
                }
                performSegue(withIdentifier: "toSearchedResult", sender: nil)
            } else {
                print("search result is nil")
                alertBySearchedResultIsNil()
            }
        } else {
            print("fail to get search text")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchedResult"{
            let searchedResultVC: SearchedResultViewController = segue.destination as! SearchedResultViewController
            searchedResultVC.searchedResults = SearchedArticles
        }
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
    
    func alertBySearchedResultIsNil(){
        let alertController = UIAlertController(title: "検索結果は0件です", message: "別のキーワードで再度検索を行ってください", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
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
        let searchWord = tempResult.word
        SearchedArticles = realm.objects(FavoriteArticle.self)
        SearchedArticles = SearchedArticles?.filter("title CONTAINS[c] %@", searchWord)
        if SearchedArticles?.count != 0 {
            performSegue(withIdentifier: "toSearchedResult", sender: nil)
            pastSearchedTableView.deselectRow(at: indexPath, animated: true)
        } else {
            alertBySearchedResultIsNil()
            pastSearchedTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            guard let realm = try? Realm() else {
                print("fail to get realm instance")
                return
            }
            do {
                try realm.write {
                    realm.delete(realm.objects(SearchWord.self)[indexPath.row])
                }
            } catch {
                print("catch the error on realm.write")
            }
            pastSearchedTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "delete") { (action, index) -> Void in
            guard let realm = try? Realm() else {
                print("fail to get realm instance")
                return
            }
            
            do {
                try realm.write {
                    realm.delete(realm.objects(SearchWord.self)[indexPath.row])
                }
            } catch {
                print("catch the error on realm.write")
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
