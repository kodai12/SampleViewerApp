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
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        pastSearchedTableView.delegate = self
        pastSearchedTableView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // searchBarのUIsetting
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        // UIRefreshControlの設定
        refreshControl.attributedTitle = NSAttributedString(string: "refresh searched words")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        pastSearchedTableView.addSubview(refreshControl)
        
        loadSearchHistory()
        pastSearchedTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSearchHistory()
        pastSearchedTableView.reloadData()
    }
    
    func refresh(){
        loadSearchHistory()
        pastSearchedTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadSearchHistory(){
        // マイグレーションの実行
        var config = Realm.Configuration(
            migrationBlock:{(migration, oldSchemaVersion) in
                migration.enumerateObjects(ofType: SearchWord.className()) { oldObject, newObject in
                    if(oldSchemaVersion < 1){}
                }
        })
        config.schemaVersion = 1
        Realm.Configuration.defaultConfiguration = config
        
        guard let realm = try? Realm(configuration: config) else{
            return
        }
        pastSearchedWords = realm.objects(SearchWord.self).sorted(byKeyPath: "date", ascending: false)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchBar.isFirstResponder{
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil{

            // 検索ワードを取得
            searchWords = (searchBar.text?.components(separatedBy: CharacterSet.whitespaces))!
            for searchWord in searchWords{
                currentSearchWord.word = searchWord
            }
            
            updateSearchedResult()
            searchBar.resignFirstResponder()
            if SearchedArticles?.count != 0 {
                print("search result is not nil")
                updateSearchWordInRealm(searchWord: currentSearchWord)
                performSegue(withIdentifier: "toSearchedResult", sender: nil)
            } else {
                print("search result is nil")
                alertBySearchedResultIsNil()
            }
        } else {
            print("fail to get search text")
        }
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
    
    func updateSearchWordInRealm(searchWord: SearchWord){
        let updateSearchWord = SearchWord()
        // 検索日時を取得
        let now = Date()
        updateSearchWord.date = now
        updateSearchWord.word = searchWord.word
        
        guard let realm = try? Realm() else{
            print("can't complete realm setting.")
            return
        }
        
        do {
            try realm.write {
                realm.add(updateSearchWord, update: true)
            }
        } catch {
            print("catch the error on realm.write")
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
        let tempResult = realm.objects(SearchWord.self).sorted(byKeyPath: "date", ascending: false)[indexPath.row]
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
    
    @IBAction func clickCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
