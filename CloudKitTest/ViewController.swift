//
//  ViewController.swift
//  CloudKitTest
//
//  Created by swstation on 9/24/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit
import Contacts
import PKHUD
import CloudKit

struct NoContactsError: Error {
    var localizedDescription: String = "No contact with photo fetched"
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let slideAnimator = SlideAnimator()
    
    let database = CKContainer.default().publicCloudDatabase
    
    var uploadedContacts = [Contact]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                HUD.hide()
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
//        fetchAllContacts()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.nib,
                           forCellReuseIdentifier: ContactTableViewCell.reuseID)
    }
    
    private func contactRecord(from contact: Contact) -> CKRecord {
        let contactToUpload = CKRecord(recordType: "Contact")
        contactToUpload.setValue(contact.fullName, forKey: "fullName")
        contactToUpload.setValue(contact.phoneNumber, forKey: "phoneNumber")
        
        let jpegImage = contact.avatar.jpegData(compressionQuality: 0.8)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(contact.fullName)
        guard let _ = try? jpegImage?.write(to: fileURL) else {
            print("error at saving to local storage")
            fatalError()
        }
        let asset = CKAsset(fileURL: fileURL)
        contactToUpload.setValue(asset, forKey: "avatar")
        return contactToUpload
    }
    
    private func fetchAllContacts() {
        HUD.show(.labeledProgress(title: "Loading...", subtitle: nil))
        let query = CKQuery(recordType: "Contact", predicate: NSPredicate(value: true))
        
        let operation = CKQueryOperation(query: query)
        var resultingArray = [Contact]()
        operation.recordFetchedBlock = { record in
            print("record - \(record)")
            guard let newContact = Contact.init(from: record) else {
                print("failed to create contact from record")
                return
            }
            resultingArray.append(newContact)
        }
        
        operation.queryCompletionBlock = { cursor, _ in
            self.uploadedContacts = resultingArray
        }
        database.add(operation)
    }
    
    private func uploadContacts(completion: @escaping (Result<Void>) -> Void) {
        let contactsToLoad = PhoneContactsManager.phoneContactsWithAvatars()
        if contactsToLoad.isEmpty {
            completion( .fail(NoContactsError() ) )
        } else {
            loadContactsToCloud(contacts: contactsToLoad) { result in
                switch result {
                case .success:
                    completion(.success( () ))
                case .fail(let error):
                    debugPrint("Uploading error - \(error)")
                }
            }
        }
    }
    
    private func loadContactsToCloud(contacts: [Contact], completion: @escaping (Result<Void>) -> Void) {
        var records = [CKRecord]()
        var resultingContacts = [Contact]()
        for contact in contacts {
            let contactToUpload = contactRecord(from: contact)
            records.append(contactToUpload)
        }
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = {[weak self] saved, ids, error in
            if let savingError = error {
                debugPrint(savingError)
                completion(.fail(savingError))
            } else {
                print("Saved to iCloud")
//                print("\(saved?.compactMap{ $0.recordID.recordName } )")
                for item in saved! {
                    if let contact = Contact.init(from: item) {
                        resultingContacts.append(contact)
                    }
                }
                self?.uploadedContacts = resultingContacts
                completion(.success( () ))
            }
        }
        database.add(operation)
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        HUD.show(.labeledProgress(title: "Uploading...", subtitle: nil))
        DispatchQueue.global().async { [weak self] in
            self?.uploadContacts { result in
                DispatchQueue.main.async {
                    HUD.hide()
                    self?.tableView.reloadData()
                }
                switch result {
                case .success:
                    debugPrint("Uploaded")
                case .fail:
                    debugPrint("Error at uploading contacts")
                }
            }
        }
    }
    
    private func addToFavorite(contactIndex: Int) {
        let favorites = CKRecord(recordType: "Favorites")
        let addingContact = uploadedContacts[contactIndex]
        let addingContactRecord = contactRecord(from: addingContact)
        let reference = CKRecord.Reference(recordID: addingContactRecord.recordID, action: .deleteSelf)
        let referenceArray = [reference]
        favorites["contacts"] = referenceArray
        
        database.save(favorites) { (record, error) in
            if let savingError = error {
                debugPrint("saving erorr - \(savingError)")
            } else {
                debugPrint("Saved to favorites")
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        destination.transitioningDelegate = slideAnimator
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uploadedContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseID, for: indexPath)  as? ContactTableViewCell else {
            fatalError("wrong cell id")
        }
        cell.favoritePressed = { [weak self] in
            self?.addToFavorite(contactIndex: indexPath.row)
        }
        cell.update(contactName: uploadedContacts[indexPath.row].fullName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

