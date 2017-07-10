//
//  SearchedResultViewController.swift
//  co-mediaViewer
//
//  Created by 迫地康大 on 2017/07/02.
//  Copyright © 2017年 sakochi. All rights reserved.
//

import UIKit
import RealmSwift

class SearchedResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var searchedResultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    
    var selectedTitle = String()
    var selectedURLString = String()
    var refreshControl = UIRefreshControl()
    
    var searchWords = [String]()
    var searchedResults: Results<FavoriteArticle>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchedResultTableView.delegate = self
        searchedResultTableView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // searchBarのUIsetting
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.showsCancelButton = true
        
        // UIRefreshControlの設定
        refreshControl.attributedTitle = NSAttributedString(string: "refresh articles")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        searchedResultTableView.addSubview(refreshControl)
    }
    
    func refresh(){
        updateSearchedResult()
        searchedResultTableView.reloadData()
        refreshControl.endRefreshing()
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchBar.isFirstResponder{
            searchBar.endEditing(true)
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
        self.dismiss(animated: true, completion: nil)
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
            cell.searchedResult = unwrappedResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let unwrappedURLString = searchedResults?[indexPath.row].url, let unwrappedTitle = searchedResults?[indexPath.row].title{
            selectedTitle = unwrappedTitle
            selectedURLString = unwrappedURLString
        }
        print("selectedURLString: \(selectedURLString)")
        performSegue(withIdentifier: "fromSearchScreentoDetail", sender: nil)
        searchedResultTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromSearchScreentoDetail"{
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
                    realm.delete(RealmModel.realm.usersSet[indexPath.row])
                }
            } catch {
                print("catch the error on realm.write")
            }
            searchedResultTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "delete") { (action, index) -> Void in
            let realm = RealmModel.realm.realmTry
            do {
                try realm.write {
                    realm.delete(RealmModel.realm.usersSet[indexPath.row])
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
