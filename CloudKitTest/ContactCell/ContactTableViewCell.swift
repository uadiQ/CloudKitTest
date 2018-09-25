//
//  ContactTableViewCell.swift
//  CloudKitTest
//
//  Created by Vadim Shoshin on 9/25/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet private weak var contactName: UILabel!
    
    
    static let reuseID = String(describing: ContactTableViewCell.self)
    static let nib = UINib(nibName: String(describing: ContactTableViewCell.self), bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var favoritePressed: (() -> Void)?
    
    func update(contactName: String) {
        self.contactName.text = contactName
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        favoritePressed?()
    }
    
}

