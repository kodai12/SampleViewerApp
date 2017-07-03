//
//  SearchedResultViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/07/02.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class SearchedResultViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchedResultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchWords = [String]()
    var searchedResults: Results<FavoriteArticle>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchedResultTableView.dataSource = self
        
        searchedResultTableView.reloadData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchBar.isFirstResponder{
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil{
            searchWords = (searchBar.text?.components(separatedBy: CharacterSet.whitespaces))!
        } else{
            print("fail to get search text")
        }
        updateSearchedResult()
        searchBar.resignFirstResponder()
        searchedResultTableView.reloadData()
        
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
        
        searchedResults = realm.objects(FavoriteArticle.self).sorted(byKeyPath: "id", ascending: false)
        for searchWord in searchWords{
            searchedResults = searchedResults?.filter("title CONTAINS[c] %@", searchWord)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedResults!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchedResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "searchedCell") as! SearchedResultTableViewCell
        if let unwrappedResults = searchedResults{
            let searchedResult = unwrappedResults[indexPath.row]
            cell.getTitle = searchedResult.title
            cell.getURLString = searchedResult.url
            cell.getImageURLString = searchedResult.imageString
        }
        cell.updateCellUI()
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
