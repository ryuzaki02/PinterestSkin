//
//  String+Custom.swift
//  ImageCachingLibrary
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit

extension String
{
    func localized(_ bundle: Bundle = .main, _ tableName: String = "CachingLocalisable") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "\(self)", comment: "")
    }
    
    func decodeBase64EncodedString() -> String? {
        guard let decryptedData = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: decryptedData, encoding: .utf8)
    }
    
    func encodeStringWithBase64Encoding() -> String {
        if let encryptedData = self.data(using: String.Encoding.utf8)
        {
            return encryptedData.base64EncodedString()
        }
        return self
    }
}
