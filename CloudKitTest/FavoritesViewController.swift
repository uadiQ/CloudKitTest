//
//  FavoritesViewController.swift
//  CloudKitTest
//
//  Created by swstation on 9/26/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit
import CloudKit
import PKHUD

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var favorites: CKRecord!
    
    var favoriteContacts: [Contact] = [] {
        didSet {
            DispatchQueue.main.async {[weak self] in
                HUD.hide()
                self?.tableView.reloadData()
            }
        }
    }
    
    let database = CKContainer.default().publicCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchFavoritesRecord()
    }
    
    private func fetchFavoritesRecord() {
        HUD.show(.labeledProgress(title: "Loading...", subtitle: ""))
        let query = CKQuery(recordType: "Favorites", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = {[weak self] record in
            print("favorites fetched")
            self?.favorites = record
            
        }
        
        operation.queryCompletionBlock = {[weak self] cursor, _ in
            if let favoritesList = self?.favorites {
                self?.fetchFavorites(from: favoritesList)
            }
        }
        database.add(operation)
    }
    
    private func fetchFavorites(from favorite: CKRecord) {
        guard let references = favorite["contacts"] as? [CKRecord.Reference] else {
            return
        }
        let referencesID = references.map { $0.recordID }
        
        let fetchOperation = CKFetchRecordsOperation(recordIDs: referencesID)
        var favoritesArray = [Contact]()
        
        fetchOperation.fetchRecordsCompletionBlock = { [weak self] records, error in
            if let responseRecords = records {
                for record in responseRecords {
                    if let contact = Contact.init(from: record.value) {
                        favoritesArray.append(contact)
                    }
                }
                self?.favoriteContacts = favoritesArray
            }
        }
        database.add(fetchOperation)
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
