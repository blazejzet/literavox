//
//  Booklist.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation

class  Booklist:ObservableObject {
     var books:[Book]?
      var folder:String?
      var count:Int?
      var type:String?
    
//    static func load(_ type:String) -> Booklist?{
//        
//        let booksjson = try? Data(contentsOf: URL(string: "\(Player.instance.server)/?type=\(type)")!, options: .uncached)
//        let x = String(data: booksjson!, encoding: .utf8)
//        print(x)
//        if let booksjson = booksjson{
//            var books = try? JSONDecoder().decode(Booklist.self, from: booksjson)
//            //print(books)
//            books?.type = type
//            return books
//        }
//        return nil
//        
//    }
}
