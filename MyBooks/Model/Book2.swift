//
//  Book2.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 29/01/2023.
//  Copyright © 2023 Blazej Zyglarski. All rights reserved.
//

import Foundation
struct Book2:Codable,Hashable{
    static func == (lhs: Book2, rhs: Book2) -> Bool {
        lhs.title == rhs.title
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    let id: String
    var type:String?
    var providercode:String?;
    var favourite: Bool = false
    var read:Bool = false
    var populating:Bool = false
    var folder: String?
    var image: String?
    var imageData: Data?
    var title: String
    var author: String?
    var tracks: [Track2]?
    var numberoftracks:Int?
    var length: Int?
}
