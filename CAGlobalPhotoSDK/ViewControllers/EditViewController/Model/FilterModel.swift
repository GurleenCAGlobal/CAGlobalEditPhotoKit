//
//  Filters.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit

// Struct representing a filter model
struct FilterModel: Decodable {
    
    // The name of the filter
    let name: String
    
    // The image associated with the filter
    let image: String
}
