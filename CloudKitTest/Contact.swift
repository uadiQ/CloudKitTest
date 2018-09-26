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
}

