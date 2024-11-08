//
//  Track.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI
import CryptoKit

class Track:Hashable,ObservableObject{
    let id = UUID()
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.filename == rhs.filename
    }
    
    func hash(into hasher: inout Hasher) {
             hasher.combine(filename)
            hasher.combine(num)
    }
    init(bookid:UUID){
        self.bookid=bookid
    }
    init(bookid:UUID,filename:String,num:Int,url:URL){
        self.bookid=bookid
        self.filename = filename
        self.num=num
        self.url = url
        let info = url.info()
        self.length = Int(info.duration)
    }
    
    var filename:String?
    var length:Int?
    var start:Int?
    var num:Int?
    var url:URL?
    
    @Published var percent:Double? {
        didSet{
            print("changing!!! to \(percent)")
        }
    }
    
    @Published var bookmarksTags = ObservableArray(array: [Bookmark]())
    
    enum CodingKeys: CodingKey {
        case filename
        case length
        case num
    }
    
    var bookmarks:Int? = 0
    var bookid:UUID
    
    func getFileHash() -> String{
        var n = "\(self.filename) \(self.bookid) \(self.num)"
        var x = Insecure.MD5.hash(data: n.data(using: .utf8)!).map{
                String(format: "%02hhx", $0)
            }.joined()
        print ("HASH \(x).mp3")
        return "\(x).mp3"
    }
    
    func setup(num:Int, book:Book, overall:Int)->Int{
        self.percent = 0.0
        self.bookid = book.id
        self.num = num
        self.start = overall
        return length!
        //self.bookmarksTags = []
    }
    
    func prevBookmark(){
        var previous = 0.0
        for bookmark in bookmarksTags.array.sorted(by: {$0.percent<$1.percent}){
            if bookmark.percent < percent! {
                previous = bookmark.percent
            }
        }
        self.percent = previous
    }
    func nextBookmark(){
        var next = 1.0
        for bookmark in bookmarksTags.array.sorted(by: {$0.percent<$1.percent}).reversed(){
            if bookmark.percent > percent! {
                next = bookmark.percent
            }
        }
        self.percent = next
    }
    func addBookmark(){
        for b in bookmarksTags.array{
            if b.close(self.percent!) {
                self.bookmarksTags.array.removeAll(where: {
                    $0.percent == b.percent
                })
                self.percent! += 0.0001
                self.bookmarks = bookmarksTags.array.count
                return
            }
        }
        print("Adding bookmark")
        
        if let p = percent{
            self.bookmarksTags.append(Bookmark(percent: p))
        }
        self.percent! += 0.0001
        self.bookmarks = bookmarksTags.array.count
        print(bookmarksTags.array)
    }
    func hasCloseBookmark()->Bool{
        for b in bookmarksTags.array{
            if b.close(self.percent!) {
                return true
            }
        }
        return false
    }
}


class Bookmark:Codable, Hashable,ObservableObject{
    static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
        lhs.percent == rhs.percent
    }
    
    var percent:Double
    func hash(into hasher: inout Hasher) {
                hasher.combine(percent)
               
       }
    func close(_ d:Double)->Bool{
        return abs(percent - d) < 0.03
    }
    func h(_ d:Double)->CGFloat{
        return CGFloat( self.close(d) ? 12 : 6)
    }
    func o(_ d:Double)->CGFloat{
          return CGFloat( self.close(d) ? 3 : 0 )
       }
       
    init(percent: Double) {
        self.percent = percent
    }
}
