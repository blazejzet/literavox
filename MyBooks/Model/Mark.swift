//
//  mark.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI
struct Mark:Decodable{
    var icon:String
    var color:Color
    
    static let def = Mark(icon: "book", color: .black)
    static let adult = Mark(icon: "ant", color: .red)
    static let children = Mark(icon: "ant", color: .red)

}

extension Color:Decodable{
    enum CodingKeys: String, CodingKey {
        case r
        case g
        case b
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let r = try values.decode(Double.self, forKey: .r)
        let g = try values.decode(Double.self, forKey: .g)
        let b = try values.decode(Double.self, forKey: .b)
        
        self.init(red: r, green: g, blue: b)
    }
}
