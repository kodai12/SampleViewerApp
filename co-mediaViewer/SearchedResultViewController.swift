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
    
    var selectedTitle = String()
    var selectedURLString = String()
    
    var searchWords = [String]()
    var searchedResults: Results<FavoriteArticle>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchedResultTableView.delegate = self
        searchedResultTableView.dataSource = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // navigationBarの生成
        let navBar = UINavigationBar(frame: CGRect(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        navBar.barTintColor = UIColor(red:0.05, green:0.50, blue:0.32, alpha:0.8)
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
    }
    
    func clickBackButton(){
        let searchVC: SearchViewController = storyboard?.instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
        present(searchVC, animated: false, completion: nil)
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
            try! realm.write {
                realm.delete(RealmModel.realm.usersSet[indexPath.row])
            }
            searchedResultTableView.deleteRows(at: [indexPath], with: .fade)
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
