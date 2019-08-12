//
//  ImageModel.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit

struct ImageModel: Codable {
    
    var imageID: String?
    var imageUrls: ImageURLModel?
    var width: Double?
    var height: Double?
    
    enum CodingKeys: String, CodingKey{
        case imageID = "id"
        case imageUrls = "urls"
        case width = "width"
        case height = "height"
    }
}
