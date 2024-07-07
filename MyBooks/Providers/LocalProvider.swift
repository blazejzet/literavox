//
//  LocalProvider.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
import ID3TagEditor

@MainActor
class LocalProvider:Provider {
      
    var inProgress=false
    var server: String //really a folder
    var url: URL?
    
    static var aqueue:DispatchQueue{
        DispatchQueue(label: "file_analysing_queue")
    }
   
    init(mark:Mark, server:String, name:String){
        self.server  = server
        super.init(symbol:mark , instancename:name, books: [], providercode:  "SS-\(Int.random(in: 0...1000000))")
        
        
    }
    
    init(dict: [String:Any]) {
        LocalProvider.name="Local storage"
        LocalProvider.description="This will be stored on Your phone or in iCloud. You can share Your iCloud location with friends, as well asx use and manage it on all Your devices."
        LocalProvider.icon="iphone"
        
        self.server = dict["server"] as? String ?? "?"
       
        var color = UIColor.green
        if let colorarray = dict["background"] as? [String:CGFloat] {
             color = UIColor(red: colorarray["r"] ?? 0.0 , green: colorarray["g"]  ?? 0.0, blue:colorarray["b"]   ?? 0.0, alpha: 1.0)

        }
        var icon = dict["icon"] as? String ?? "creditcard"
        var symbol = Mark(icon: icon, color: Color(uiColor: color))
        super.init(symbol:symbol , instancename: dict["name"] as? String ?? "?", books: [], providercode:  "SS-\(Int.random(in: 0...1000000))")
        
        
        if let folder_access_data = dict["bd"] as? Data{
            self.url = restoreFileAccess(with: folder_access_data)
        }
    }
    
    private func restoreFileAccess(with bookmarkData: Data) -> URL? {
        do {
            
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
                url.startAccessingSecurityScopedResource()
                    print("Bookmark is stale, need to save a new one... ")
                    DispatchQueue.main.async {
                          Library.global.saveBookmarkData(for: url)
                    }
                 
                    return url
                } catch {
                    print("Error resolving bookmark:", error)
                    return nil
                }
            }
    
    override func loadBooks() {
        DispatchQueue.main.async {
            self.books.removeAll()
            self.inProgress = true
        }
        DispatchQueue.global().async {
            
            
            Task{
                
                await self.url?.startAccessingSecurityScopedResource()
                if let url = await self.url, let dircontent =  try? await FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil){
                    
                    var jsonurl =  url
                    jsonurl.appendPathComponent("json.json",conformingTo: .json)
                    print (jsonurl.relativePath)
                    if FileManager.default.fileExists(atPath: jsonurl.relativePath){
                        if let data = try? Data(contentsOf: jsonurl){
                            if let b = try? JSONDecoder().decode([Book2].self, from: data){
                                print("[DC] Read \(b.count) books from \(url)")
                                if b.count==0{
                                    MXContextMenuModel.global.showContextSheet(content: AnyView(
                                        VStack{
                                            Text("Sorry! There is no books in the \(url.lastPathComponent) library.").fontWeight(.bold)
                                            Text("Please mind the folders structure in selected library folder.")
                                            
                                            Image("lib").resizable().scaledToFit().frame(width: 300.0)
                                             
                                            Button(action:{
                                                
                                                MXContextMenuModel.global.hideContextMenu()
                                            }){
                                                
                                                Image(systemName: "xmark").font(.system(size: 25)).foregroundColor(.white)
                                                Text("Close").foregroundColor(.white)
                                                
                                            }.padding(12).background(Rectangle().foregroundColor(.black).cornerRadius(20.0))
                                        }
                                    ))
                                }
                                self.objectWillChange.send()
                                DispatchQueue.main.async {
                                    
                                    
                                    Library.global.objectWillChange.send()
                                    self.books.append(contentsOf:  b)
                                }
                              
                                if dircontent.filter{$0.hasDirectoryPath}.count == self.books.count{
                                    DispatchQueue.main.async {
                                        self.inProgress = false
                                    }
                                    return
                                }
                                
                            }
                        }
                    }
                    print("[DC] \(dircontent.filter{$0.hasDirectoryPath}.count) \(url)")
                    if (dircontent.filter{$0.hasDirectoryPath}.count == 0){
                        MXContextMenuModel.global.showContextSheet(content: AnyView(
                            VStack{
                                Text("Sorry! There is no books in the \(url.lastPathComponent) library.").fontWeight(.bold)
                                Text("Please mind the folders structure in selected library folder.")
                                
                                Image("lib").resizable().scaledToFit().frame(width: 300.0)
                                 
                                
                                Button(action:{
                                    
                                    MXContextMenuModel.global.hideContextMenu()
                                }){
                                    
                                    Image(systemName: "xmark").font(.system(size: 25)).foregroundColor(.white)
                                    Text("Close").foregroundColor(.white)
                                    
                                }.padding(12).background(Rectangle().foregroundColor(.black).cornerRadius(20.0))
                            }
                        ))
                    }
                    var todo=0
                    for bookurl in dircontent.filter{$0.hasDirectoryPath}{
                            //probably a book
                            todo += 1
                            await self.book(from:bookurl) { book in
                                Library.global.objectWillChange.send()
                                self.books.removeAll{$0.id == book.id}
                                print("[A] apending \(book.title)")
                                self.books.append(book)
                                todo -= 1
                                if todo == 0 {
                                    DispatchQueue.main.async {
                                        self.inProgress = false
                                    }
                                }
                            
                        }
                    }
                }
                await self.save()
                await  self.url?.stopAccessingSecurityScopedResource()
                
            }
        }
    }
    
    func save(){
        Task{
            await url?.startAccessingSecurityScopedResource()
            let json = try? JSONEncoder().encode(books)
            if var jsonurl = await url {
                jsonurl.appendPathComponent("json.json",conformingTo: .json)
                try? json?.write(to: jsonurl)
            }
        }
    }
    
    func book(from dir:URL, rx:@escaping(Book2)->Void){
        Task{
            if let   dircontent =  try? FileManager.default.contentsOfDirectory(at:dir,includingPropertiesForKeys: nil ){
                var infopresent = false
                
                for e in dircontent{
                    if e.lastPathComponent.contains("info.txt"){
                        infopresent = true
                        self.getData(from: e) { book in
                            //rx(book)
                            for z in dircontent{
                                if z.lastPathComponent.contains("cover.jpg") || z.lastPathComponent.contains("cover.jpeg"){
                                    self.getImage(from:z, for: book){ book in
                                        rx(book)
                                        self.getTracks(from: dir,for: book){ book in
                                            rx(book)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                }
                if !infopresent{
                    
                    print("[ID3] No info for \(dir.relativePath)")
                    if let fistm3 = dircontent.filter{$0.relativePath.contains(".mp3")}.first {
                        print("[ID3] Opening \(fistm3.relativePath)")
                        fistm3.iCloud().downloadFromiCloud{_,_,url in
                            if let data = try? Data(contentsOf: url!){
                                
                                print("[ID3] Read \(data.count)b of file")
                                let id3TagEditor = ID3TagEditor()
                                
                                if let id3Tag = try? id3TagEditor.read(mp3: data) {
                                    
                                    var title = ((id3Tag.frames[.Title] as?  ID3FrameWithStringContent)?.content ?? "")
                                    var author = ((id3Tag.frames[.Artist] as? ID3FrameWithStringContent)?.content ?? "")
                                    var bookt = ((id3Tag.frames[.Album] as? ID3FrameWithStringContent)?.content ?? "")
                                    var coverData = ((id3Tag.frames[.AttachedPicture(.FrontCover)] as? ID3FrameAttachedPicture)?.picture ?? Data())
                                    //print("[ID3] \(coverB64)")
                                    ///Data(
                                    print("[ID3] Read \(author):\(bookt)")
                                    if let coverurl = url?.coverURL(){
                                        if coverData.count > 0{
                                            try? coverData.write(to: coverurl)
                                            print("[ID3] Writing \(coverData.count)b to \(coverurl)")
                                        }else{
                                            if let u =  URL(string:"https://www.googleapis.com/books/v1/volumes?q=\(bookt.plus())+\(author.plus())"),
                                               let data = try? Data(contentsOf: u),
                                               let r = try? JSONDecoder().decode(GResp.self, from: data),
                                               let imgurls = r.items.first?.volumeInfo.imageLinks.thumbnail,
                                               let imgurl = URL(string: imgurls),
                                               let pdata = try? Data(contentsOf: imgurl){
                                                try? pdata.write(to: coverurl)
                                            }
                                        }
                                        
                                        if let infourl = url?.infotxtURL(){
                                            try? "TITLE=\(bookt)\nAUTHOR=\(author)".write(to: infourl, atomically: true, encoding: .utf8)
                                            print("[ID3] Writing to \(infourl)")
                                            
                                            self.getData(from: infourl) { book in
                                                
                                                self.getImage(from:coverurl, for: book){ book in
                                                    self.getTracks(from: dir,for: book){ book in
                                                        rx(book)
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    func getData(from url:URL,r:@escaping(Book2)->Void){
        url.downloadFromiCloud{
            ready, progress, url in
            if let url = url {
                guard let  content = try? String(contentsOf: url).split(separator: "\n") else {return}
                var title = ""
                var author = ""
                for val in content{
                        var data = val.split(separator: "=")
                        switch "\(data[0])"{
                        case "TITLE": title = "\(data[1])"
                        case "AUTHOR": author = "\(data[1])"
                        default: break;
                        }
                    }
                
                r(Book2(id: "\(title)-\(author)".md5(), title: title, author: author))
                
            }
        }
    }
    func getImage(from url:URL, for book:Book2,r:@escaping(Book2)->Void){
        url.downloadFromiCloud{ ready, progress, url in
            if let url = url {
                DispatchQueue.main.async{
                    var newbook = book
                    newbook.imageData = try? Data(contentsOf: url)
                    r(newbook)
                }
            }
        }
    }
    func getTracks(from url:URL, for book:Book2,r:@escaping(Book2)->Void){
        let semaphore = DispatchSemaphore(value: 1)
        var newbook = book
        newbook.tracks = [Track2]()
        if let   dircontent =  try? FileManager.default.contentsOfDirectory(at:url,includingPropertiesForKeys: nil ){
           
            var left = dircontent.filter{ $0.lastPathComponent.contains(".mp3") && !$0.lastPathComponent.contains(".info") }.count
            
            for e in dircontent{
                if e.lastPathComponent.contains(".mp3") && !e.lastPathComponent.contains(".info") {
                    //e.downloadFromiCloud{ _, _, noicloudurl in
                        var track = Track2(filename:  e.noiCloud().lastPathComponent, length: 0, start: 0, num: 0, url: e.noiCloud(), bookmarksTags: [], bookmarks: 0,percent:0)
                        newbook.numberoftracks = (newbook.numberoftracks ?? 0) +  1
                        let info = e.noiCloud().info()
                        track.length = Int(info.duration)
                        newbook.tracks?.append(track)
                        left = left - 1
                        if left == 0 {
                            semaphore.signal()
                        }
                    //}
                }
            }
            
            semaphore.wait()
            newbook.tracks?.sort{
                var d0 = $0.filename!.components(separatedBy:CharacterSet(charactersIn: " +-_"))[0]
                var d1 = $1.filename!.components(separatedBy:CharacterSet(charactersIn: " +-_"))[0]
                return $0.filename! < $1.filename!
                
            }
            var start = 0
            for i in 0 ..< newbook.tracks!.count {
                newbook.tracks?[i].num = i+1
                newbook.tracks?[i].start = start
                start += (newbook.tracks?[i].length ?? 0)
            }
            newbook.length = start
                
            
            
        }
        r(newbook)
    }
}



extension String{
    func md5()->String{
        let string = self
        let length = Int(CC_MD5_DIGEST_LENGTH)
       let messageData = string.data(using:.utf8)!
       var digestData = Data(count: length)

       _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
           messageData.withUnsafeBytes { messageBytes -> UInt8 in
               if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                   let messageLength = CC_LONG(messageData.count)
                   CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
               }
               return 0
           }
       }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    func plus()->String{
        return self.replacingOccurrences(of: " ", with: "+")
    }
}




struct GResp: Codable{
    let items:[GBook]
}

struct GBook:Codable{
    let volumeInfo: VInfo
}

struct VInfo:Codable{
    let imageLinks: ILinks
}

struct ILinks:Codable{
    let smallThumbnail:String
    let thumbnail:String
    
}
