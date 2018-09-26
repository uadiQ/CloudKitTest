//
//  Contact.swift
//  CloudKitTest
//
//  Created by swstation on 9/24/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit
import CloudKit

struct Contact {
    let fullName: String
    let phoneNumber: String
    let avatar: UIImage
    let recordID: String?
    
    init(fullName: String, phoneNumber: String, avatar: UIImage, recordID: String? = nil) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.avatar = avatar
        self.recordID = recordID
    }
    
    init?(from record: CKRecord) {
        let name = record.value(forKey: "fullName") as? String ?? ""
        let number = record.value(forKey: "phoneNumber") as? String ?? ""
        let recordID = record.recordID.recordName
        guard let avatarAsset = record.value(forKey: "avatar") as? CKAsset,
            let avatarImage = UIImage(contentsOfFile: avatarAsset.fileURL.path) else {
                return nil
        }
        self.init(fullName: name,
                  phoneNumber: number,
                  avatar: avatarImage,
                  recordID: recordID)
    }
    
    func record() -> CKRecord {
        let contactToUpload: CKRecord
        if let recordName = self.recordID {
            let contactID = CKRecord.ID(recordName: recordName)
            contactToUpload = CKRecord(recordType: "Contact", recordID: contactID)
        } else {
            contactToUpload = CKRecord(recordType: "Contact")
        }
        contactToUpload.setValue(self.fullName, forKey: "fullName")
        contactToUpload.setValue(self.phoneNumber, forKey: "phoneNumber")
        let jpegImage = self.avatar.jpegData(compressionQuality: 0.8)
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self.fullName)
        guard let _ = try? jpegImage?.write(to: fileURL) else {
            print("error at saving to local storage")
            fatalError()
        }
        let asset = CKAsset(fileURL: fileURL)
        contactToUpload.setValue(asset, forKey: "avatar")
        return contactToUpload
    }
}

