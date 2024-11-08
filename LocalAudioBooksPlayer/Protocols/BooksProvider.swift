//
//  BooksProvider.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation

protocol BooksProvider{
    var uploader:BooksUploader? {get set} // set only if service provides upload.
    
    var providercode:String {get set}
    
    var symbol:Mark {get set}
    var name:String{get set}
    func provides(_book:Book)->Bool
    var inProgress:Bool {get set}
    //NEW
    func loadBooks(of type:String,cl:((Bool)->Void)?) //cl odpalany gdy uda się zaladowac ksiazki
    func loadBookData(book:Book,cl:(()->Void)?)->Book
    
    func getLocalFile(for track:Track, inBook book:Book,cb:@escaping ((URL)->Void));
    
    func getFileHash(for track: Track) -> String;
    
    
    static var name:String {get}
    static var description:String {get}
    static var icon:String {get}
   
}



class Provider: Identifiable,Hashable,ObservableObject{
    static func == (lhs: Provider, rhs: Provider) -> Bool {
        lhs.instancename == rhs.instancename
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.instancename)
    }
    
    var symbol:Mark
    var instancename:String
    @Published var books:[Book2]
    @Published var providercode:String
    static var name:String = ""
    static var description:String = ""
    static var icon:String = ""
    
    func loadBooks(){}
    
    init(symbol: Mark, instancename: String, books: [Book2], providercode: String) {
        self.symbol = symbol
        self.instancename = instancename
        self.books = books
        self.providercode = providercode
    }
   
}

