//
//  PhoneContactsManager.swift
//  CloudKitTest
//
//  Created by Vadim Shoshin on 9/25/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit
import Contacts

class PhoneContactsManager {
    static func phoneContactsWithAvatars() -> [Contact] {
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
}
