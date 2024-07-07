//
//  Types.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation

class Types:ObservableObject{
    @Published var types:[Type]?
     @Published var count:Int?
    
//    static func load()->Types?{
//        if let typesjson = try? Data(contentsOf: URL(string: "\(Player.instance.server)")!, options: .uncached){
//            
//            return try? JSONDecoder().decode(Types.self, from: typesjson)
//            
//        }
//        return nil
//    }
}
