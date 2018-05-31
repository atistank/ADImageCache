//
//  File.swift
//  ADImageCatch
//
//  Created by Apple on 5/14/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
//Mart : - Model
struct photoAPI: Codable {
    var url: String = ""
}


struct photoAPIList: Codable {
    var listUrl: [photoAPI]
}
