//
//  SearchViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/07/01.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pastSearchedTableView: UITableView!
    
    var searchWord: String?
    var searchedWordArray = [String]()
    var exampleWord = ["あ","鹿児島","宮崎","コーヒー","プログラミング"]
    
    var SearchedArticles:Results<FavoriteArticle>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        pastSearchedTableView.delegate = self
        pastSearchedTableView.dataSource = self
        
        searchedWordArray = exampleWord
        updateSearchedResult()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchWord = searchBar.text
        searchBar.resignFirstResponder()
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
            print("can't get realm instance")
            return
        }
        
        SearchedArticles = realm.objects(FavoriteArticle.self).sorted(byKeyPath: "id", ascending: false)
        if let searchBar = searchBar, let queries = searchBar.text?.components(separatedBy: CharacterSet.whitespaces){
            for query in queries{
                SearchedArticles = SearchedArticles?.filter("text CONTAINS[c] %@", query)
            }
        }
        self.SearchedArticles = SearchedArticles
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedWordArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "searchWordCell") as! SearchTableViewCell
        cell.searchedWord = searchedWordArray[indexPath.row]
        cell.updateCellUI()
        return cell
    }
    
    @IBAction func clickCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
