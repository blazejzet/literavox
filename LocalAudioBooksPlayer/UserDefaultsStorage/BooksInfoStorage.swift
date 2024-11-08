//
//  BooksInfoStorage.swift
//  LocalAudioBooksPlayer
//
//  Created by Dawid Jenczewski on 06/01/2021.
//  Copyright © 2021 Blazej Zyglarski. All rights reserved.
//

import Foundation

class BooksInfoStorage{
    
    //Dictionary<bookID,bookInfo>
    private var booksInfo: Dictionary< String, Dictionary< String, Any>>?
    
    init(){
        self.booksInfo = UserDefaults.standard.dictionary(forKey: "booksInfo") as? Dictionary< String, Dictionary< String, Any>>
    }
    
    
    
    func setValueFor(bookID id: String, currentTime time : Int? = nil, favourite fav: Bool? = nil, read : Bool? = nil){
        
        if self.booksInfo == nil {
            
            let bookInfo : Dictionary< String, Any> = ["lastTime":0,"favourite":false,"read":false]
            self.booksInfo = ["\(id)":bookInfo]
            
        }
        
        let bookInfo = self.booksInfo?["\(id)"]
        
        var sfav : Bool = false
        if let bfav = bookInfo?["favourite"] as? Bool {
            sfav = (fav == nil ? bfav:fav) ?? bfav
        } else{
            sfav = (fav == nil ? false:fav) ?? false
        }
        
        var stime : Int = 0
        if let btime = bookInfo?["lastTime"] as? Int{
            stime = (time == nil ? btime:time) ?? btime
        }else{
            stime =  (time == nil ? 0:time) ?? 0
        }
        
        var sread : Bool = false
        if let bread = bookInfo?["read"] as? Bool{
            sread = (read == nil ? bread:read) ?? bread
        }else{
            sread = (read == nil ? false:read) ?? false
        }
        
        if(self.booksInfo != nil){
            self.booksInfo?["\(id)"] = ["lastTime":stime, "favourite": sfav, "read": sread]
        }
        
        
        
        UserDefaults.standard.set(self.booksInfo, forKey: "booksInfo")
        UserDefaults.standard.synchronize()
    }
    
    func lastTime(bookId id: String) -> Int{
        let bookInfo = self.booksInfo?["\(id)"]
        if let time = bookInfo?["lastTime"] as? Int{
            return time
        }
        return 0
    }
    func favValue(bookID id : String) -> Bool{
        let bookInfo = self.booksInfo?["\(id)"]
        if let fav = bookInfo?["favourite"] as? Bool{
            return fav
        }
        return false
    }
    func readValue(bookID id : String) -> Bool{
        let bookInfo = self.booksInfo?["\(id)"]
        if let readValue = bookInfo?["read"] as? Bool{
            return readValue
        }
        return false
    }
    
    
}
