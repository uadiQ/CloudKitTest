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
    
    let database = CKContainer.default().publicCloudDatabase
    
    var uploadedContacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.nib,
                           forCellReuseIdentifier: ContactTableViewCell.reuseID)
    }
    
    private func getAllContacts() -> [Contact] {
        var result = [Contact]()
        let contactStore = CNContactStore()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey,
                    CNContactImageDataKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                for phoneNumber in contact.phoneNumbers {
                    if let imageData = contact.imageData,
                        let image = UIImage(data: imageData) {
                        
                        let fullName = contact.familyName + " " + contact.givenName
                        let phoneNumber = phoneNumber.value.stringValue
                        let newContact = Contact.init(fullName: fullName,
                                                      phoneNumber: phoneNumber,
                                                      avatar: image)
                        result.append(newContact)
                        print("Contact \(newContact.fullName) added")
                    }
                    
                }
            }
        } catch {
            print("unable to fetch contacts")
        }
        return result
    }
    
    //ckreference to add favs
    
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
    
    
    private func fetchContacts(completion: (Result<[String]>) -> Void) {
        
    }
    
    private func uploadContacts(completion: @escaping (Result<Void>) -> Void) {
        let contactsToLoad = getAllContacts()
        if contactsToLoad.isEmpty {
            completion( .fail(NoContactsError() ) )
        } else {
            loadContactsToCloud(contacts: contactsToLoad) { result in
                switch result {
                case .success:
                    completion(.success( () ))
                case .fail(let error):
                    debugPrint("Uploading error")
                }
            }
        }
        
    }
    
    private func loadContactsToCloud(contacts: [Contact], completion: @escaping (Result<Void>) -> Void) {
        var records = [CKRecord]()
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
                print("\(saved?.compactMap{ $0.recordID.recordName } )")
                self?.fetchRecords()
                completion(.success( () ))
            }
        }
        database.add(operation)
    }
    
    private func fetchRecords() {
        let query = CKQuery(recordType: "Contact", predicate: NSPredicate(value: true))
        
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = {
            print("\($0)")
        }
        
        operation.queryCompletionBlock = { cursor, _ in
            
        }
        
        database.add(operation)
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        HUD.show(.labeledProgress(title: "Uploading...", subtitle: nil))
        DispatchQueue.global().async { [weak self] in
            guard let contacts = self?.getAllContacts() else {
                print("Didnt access to contacts")
                return
            }
            
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
        
    }
    
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
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    
}

