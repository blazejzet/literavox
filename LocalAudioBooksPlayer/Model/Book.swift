//
//  Book.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI

class Book:ObservableObject, Hashable{
     
    let id = UUID()
    static let example = Book()
    var symbol:Mark?
    var type:String?
    var providercode:String?;
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
             hasher.combine(title)
            hasher.combine(id)
    }
    
    @Published var favourite: Bool = false
    @Published var read:Bool = false
    @Published var populating:Bool = false
    var folder: String?
    var image: String?
    var imageData: Data?
    var title: String?
    var author: String?
    //var id: String?
    var tracks: [Track]?
    var numberoftracks:Int?
    var length: Int? 
    
    ///define values to decode
    enum CodingKeys : String,CodingKey{
        case folder
        case image
        case title
        case author
        case id
        case tracks
        
    }

    init() {
        self.title="Empty element"
    }
    
    func getLength()->Double{
        var length:Double = 0.0
        
        for track in tracks ?? []{
            length += Double(track.length ?? 0)
        }
        
        return length
    }
    /*required init(from decoder: Decoder) throws {
        decoder.codingPath.append(contentsOf: [CodingKey. )])
    }*/
   
//     func downloadData(type:String,cb:(()->Void)){
//        print(self)
//        let booksjson = try? Data(contentsOf: URL(string: "\(Player.instance.server)/?type=\(type)&bookid=\(self.id!)")!, options: .uncached)
//        if let booksjson = booksjson{
//            print(String(data: booksjson, encoding: .utf8))
//
//            var b  = try! JSONDecoder().decode(Book.self, from: booksjson)
//            //self.folder = b.folder
//            //self.image = b.image
//            self.tracks = b.tracks
//            for i in 0..<self.tracks!.count{
//                self.tracks![i].num=i
//            }
//            self.numberoftracks = b.numberoftracks
//            self.trackspercentage = []
//            for track in self.tracks!{
//                self.trackspercentage?.append(0.0)
//            }
//            cb()
//        }
//    }
}
