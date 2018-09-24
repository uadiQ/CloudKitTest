//
//  Result.swift
//  CloudKitTest
//
//  Created by swstation on 9/24/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import Foundation

enum Result<T>: Error {
    case success(T)
    case fail(Error)
}
