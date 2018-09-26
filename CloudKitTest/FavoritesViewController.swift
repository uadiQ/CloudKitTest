//
//  FavoritesViewController.swift
//  CloudKitTest
//
//  Created by swstation on 9/26/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit
import CloudKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var favorites: CKRecord! {
        didSet {
            //reload table here
        }
    }
    
    var favoriteContacts: [Contact] = []
    
    
    let database = CKContainer.default().publicCloudDatabase

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFavoritesRecord()
    }
    
    private func fetchFavoritesRecord() {
        let query = CKQuery(recordType: "Favorites", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = {[weak self] record in
            print("favorites fetched")
            self?.favorites = record
        }
        
        operation.queryCompletionBlock = { cursor, _ in
            
        }
        
        database.add(operation)
    }
    
    private func fetchFavorites(from favorite: CKRecord) {
        guard let references = favorite["contacts"] as? [CKRecord.Reference] else {
            return
        }
        
        for item in references {
            let recordID = item.recordID
            database.fetch(withRecordID: recordID) { [weak self] (record, error) in
                if let fetchingError = error {
                    debugPrint("fetching error - \(fetchingError)")
                } else {
                    
                }
            }
        }
    }
    
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.nib, forCellReuseIdentifier: ContactTableViewCell.reuseID)
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseID, for: indexPath) as? ContactTableViewCell else {
            fatalError("wrong id of cell")
        }
        
        let name = favoriteContacts[indexPath.row].fullName
        cell.update(contactName: name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteContacts.count
    }
}
