//
//  ImageURLs.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import Foundation

struct ImageURLModel: Codable {
    var imageUrlRegular: String?
    var imageUrlSmall: String?
    var imageUrlFull: String?
    
    enum CodingKeys: String, CodingKey {
        case imageUrlFull = "full"
        case imageUrlSmall = "small"
        case imageUrlRegular = "regular"
    }
}
