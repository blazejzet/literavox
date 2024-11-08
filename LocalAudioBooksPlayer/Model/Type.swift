//
//  Type.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation


class Type:ObservableObject{
    var name:String?
    var file:String?
    var books:Booklist?
    
//    mutating func load(){
//        if let n = self.file {
//            self.books = Booklist.load(n)
//        }
//    }
}

