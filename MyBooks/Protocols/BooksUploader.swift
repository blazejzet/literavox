//
//  BooksUploader.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 12/08/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation



protocol BooksUploader{
    //TODO: figure out what functions and parameters are needed etc;
    func createBook(name:String,author:String) -> String; //returns some key
    func uploadBook();
    func uploadChapter();
    func getStatus();
    
    
}
    
