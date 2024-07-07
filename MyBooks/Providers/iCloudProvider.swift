//
//  SimpleServer.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI

class iCloudProvider:BooksProvider {
  
    var inProgress: Bool = false
    static var name:String {"iCloud storage"}
    static var description:String {"This will be stored on Your iCloud account, so it will be available to share, but it will Use your storage capacity "}
    static var icon:String {"icloud"}
   
   
    
    func provides(_book: Book) -> Bool {
        //print(" \(self.providercode) == \(_book.providercode)")
        return self.providercode == _book.providercode
        
    }
    
    var uploader: BooksUploader?
    var type:String = ""
    var providercode: String
    var symbol: Mark = Mark.def
    var name:String = "iCloud storage"
    
    var destination: BooksRepository?
    
    init(destination:BooksRepository){
        self.destination = destination
        self.providercode = "SS-\(Int.random(in: 0...1000000))"
    }
    
    
    func loadBooks(of type:String,cl:((Bool)->Void)?) {
        //Booklist
        //destination?.books.append(books)
        cl?(true);
        
    }
    func loadBookData(id: String) -> Book?{
        return nil
    }
    
    func loadBookData(book: Book,cl:(()->Void)?) -> Book {
        
//        book.tracks = newbook.tracks
//        book.length = overall
//        book.numberoftracks = newbook.numberoftracks
        return book
    }
    
    func getLocalFile(for track:Track, inBook book:Book ,cb:@escaping ((URL)->Void)){
        //pobieram i zapisuję.
        //savedURL
        
        
    }
    
    func getFileHash(for track: Track) -> String{
        return track.getFileHash()
    }
}
