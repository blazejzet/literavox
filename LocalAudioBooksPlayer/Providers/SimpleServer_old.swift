//
//  SimpleServer_old.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 29/01/2023.
//  Copyright © 2023 Blazej Zyglarski. All rights reserved.
//

import Foundation
//
//  SimpleServer.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation

class LocalStorageProvider:BooksProvider {
    var inProgress: Bool = false
    static var aqueue:DispatchQueue{
        DispatchQueue(label: "file_analysing_queue")
    }
    static var name:String {"Local storage"}
    static var description:String {"This will be stored on Your phone"}
    static var icon:String {"iphone"}
   
    
    
    
    func provides(_book: Book) -> Bool {
        //print(" \(self.providercode) == \(_book.providercode)")
        return self.providercode == _book.providercode
        
    }
    
    var uploader: BooksUploader?
    var type:String = ""
    var providercode: String
    var server: String = ""
    var symbol: Mark = Symbols.adult
    var name:String = ""
    var url:URL?
    struct Symbols {
        static let adult = Mark(icon: "book", color: .black)
        static let children = Mark(icon: "ant", color: .red)
    }
    
    
    init( ){
         
        self.providercode = "SS-\(Int.random(in: 0...1000000))"
         
    }
    init(dict:[String:Any]){
        
        self.providercode =  "SS-\(Int.random(in: 0...1000000))"
        self.server = dict["server"] as? String ?? "?"
        self.name = dict["name"] as? String ?? "?"
        if let d = dict["bd"] as? Data{
            self.url = restoreFileAccess(with: d)
        }
    }
    private func restoreFileAccess(with bookmarkData: Data) -> URL? {
        do {
            
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
            url.startAccessingSecurityScopedResource()
            
                print("Bookmark is stale, need to save a new one... ")
            DispatchQueue.main.async {
                
                
                BooksRepository.global.saveBookmarkData(for: url)
            }
                 
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
    
    func loadBooks(of type:String,cl:((Bool)->Void)?) {
        DispatchQueue.global().async { [self] in
            
            
            //let lastPlayed = destination?.getLastPlayedBookID()
            self.type = type
            
            
            
            guard let url = self.url, url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                cl?(false)
                return
                
            }
            var dircontent =  try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for bookurl in dircontent{
                //let bookurl = url.appending(
                
                if bookurl.hasDirectoryPath{
                    print("[Loading book from] \(bookurl)")
                    let book = try! Book(fromDirectory:bookurl, type:type,providercode:providercode, provider:self,symbol:symbol)
                        //books.append(book)
                        DispatchQueue.main.async {
                            
                            
                            BooksRepository.global.booksAppend([book])
                        }
                    
                    
                    
                }
            }
            
            cl?(true);//CALLBACK IF OK
            
        }
    }
    
    func loadBookData(id: String) -> Book?{
        return nil
    }
    
    func loadBookData(book: Book,cl:(()->Void)?) -> Book {
        
//        print("[PROV] loading data for \(book.title!) \(book.type!) \(book.id)")
//        var addr = "\(server)/?type=\(book.type!)&bookid=\(book.id)"
//        print (addr)
//        if let booksjson = try? Data(contentsOf: URL(string: addr)!, options: .uncached){
//            var newbook  = try! JSONDecoder().decode(Book.self, from: booksjson)
//            book.tracks = newbook.tracks
//            var overall = 0
//            for i in 0..<book.tracks!.count{
//
//                overall += book.tracks![i].setup(num:i+1,book:book,overall: overall)
//            }
//            book.length = overall
//            book.numberoftracks = newbook.numberoftracks
//            //called when all data is ready.
//            cl?()
//        }
        var overall = 0
        for i in 0..<book.tracks!.count{

            overall += book.tracks![i].setup(num:i+1,book:book,overall: overall)
        }
        book.length = overall
        book.numberoftracks = book.tracks!.count

        cl?()
        
        return book
    }
    
    func getLocalFile(for track:Track, inBook book:Book ,cb:@escaping ((URL)->Void)){
        //pobieram i zapisuję.
        print("[PROV]  \(providercode)  downloading file: \(track.filename!) for \(book.title!) \(book.id) \(track.url)")
        track.url?.downloadFromiCloud{
            _, _, url in
            if let url = url {
                let info = url.info()
                track.length = Int(info.duration)
                //book.updateLength(with:info.factor)
                cb(url)
            }
        }
        
        
    }
    
    func getFileHash(for track: Track) -> String{
        return track.getFileHash()
    }
}

var G = 0

extension Book{
    convenience init(fromDirectory url: URL,  type:String,providercode:String,provider:BooksProvider?,symbol:Mark) throws {
        G += 1
        var x = G
        self.init()
        url.startAccessingSecurityScopedResource()
        self.type = type
        self.title = "...\(self.id)"
        self.author = "..."
        self.symbol = self.symbol
        self.providercode = providercode
        self.tracks = [Track]()
        self.folder = url.absoluteString
        if let   dircontent =  try? FileManager.default.contentsOfDirectory(at:url,includingPropertiesForKeys: nil ){
            var index = 0
            var infofound = false
            for e in dircontent{
                e.startAccessingSecurityScopedResource()
               
                if e.lastPathComponent.contains("info.txt"){
                    print("[UPD][G] + \(x) + \(e.absoluteString)")
                    infofound = true
                    
                    self.populate(with:e,provider:provider)
                }
                if e.lastPathComponent.contains("cover.jpg") || e.lastPathComponent.contains("cover.jpeg"){
                    self.getImage(with:e,provider:provider)
                }
                if e.lastPathComponent.contains(".mp3") && !e.lastPathComponent.contains(".info") {
                    self.tracks?.append(Track(bookid: self.id, filename: e.noiCloud().lastPathComponent, num: index, url: e))
                    index += 1
                    DispatchQueue.main.async{
                        self.numberoftracks = index
                        BooksRepository.global.updateBook(self)
                    }
                    
                }
                self.tracks?.sort{
                    var d0 = $0.filename!.components(separatedBy:CharacterSet(charactersIn: " +-_"))[0]
                    var d1 = $1.filename!.components(separatedBy:CharacterSet(charactersIn: " +-_"))[0]
                    //if let n0 = Int(d0), let n1 = Int(d1){
                    //    return n0 < n1
                   // }else{
                        return $0.filename! < $1.filename!
                    //}
                }
                index = 1
                for t in self.tracks!{
                    t.num = index
//                    //LocalStorageProvider.aqueue.async {
//                        if let info = t.url?.info(){
//                            t.length = Int(info.duration)
//                            DispatchQueue.main.async{
//                                BooksRepository.global.updateBook(self)
//                            }
//                        }
//                    //}
                    
                    index += 1
                }
                
                
            }
            if !infofound{
                print("[INFO] NO INFO for + \(url.absoluteString)")
            }
        }
        
    }
    func populate(with infoURL:URL,provider:BooksProvider?){
        if (self.populating) {return }
        self.populating = true
        
        var done = false
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true){ t in
            t.invalidate()
            if !done {
                print("[UPD][X] NOD UPDATED \(self.id) from \(infoURL.absoluteString)")
            }
        }
        //LocalStorageProvider.aqueue.async {
            print("[UPD] Trying to update (async f ) \(self.id) from \(infoURL.absoluteString)")
          
            infoURL.downloadFromiCloud{
                ready, progress, url in
                
                if let url = url {
                    guard let  content = try? String(contentsOf: url).split(separator: "\n") else {return}
                    done = true
                    self.objectWillChange.send()
                  
                    self.populating = false
                    for val in content{
                        
                            
                            var data = val.split(separator: "=")
                            switch "\(data[0])"{
                            case "TITLE": self.title = "\(data[1])"
                            case "AUTHOR": self.author = "\(data[1])"
                            default: var x = 1
                            }
                            
                            
                        }
                    }
                DispatchQueue.main.async{
                    print("[UPD] Updating \(self.id) with \(self.title) from \(infoURL.absoluteString)")
                    BooksRepository.global.updateBook(self)
                }
                    
                }
                
            
       // }
        
    }
    
//    func updateLength(with factor:Double){
//        self.length = 0
//        for t in self.tracks!{
//            var infot.url?.info()
//            self.length = self.length! + (t.length ?? 0)
//        }
//    }
    
    func getImage(with imageURL:URL,provider:BooksProvider?){
        imageURL.downloadFromiCloud{ ready, progress, url in
            if let url = url {
                DispatchQueue.main.async{
                    self.objectWillChange.send()
                    self.imageData = try? Data(contentsOf: url)
                    BooksRepository.global.updateBook(self)
                }
            }
        }
       
    }
}



struct TrackInfo:Codable{
    let duration:Int64
    let filesize:Int64
    let factor:Double
}

extension URL{
    func info() -> TrackInfo{
        var infoURL = self.noiCloud().infoURL()
        var infoURLiCloud = self.noiCloud().infoURL().iCloud()
        var fileURL = self.noiCloud()
        
        if !FileManager.default.fileExists(atPath: infoURL.relativePath){
            //Info not exist.
            print("[D] Not exist \(infoURL.relativePath), checking for \(infoURLiCloud.relativePath)")
            if FileManager.default.fileExists(atPath: infoURLiCloud.relativePath){
                //Info exist in iCloud.
                let sem = DispatchSemaphore(value: 1)
                print("[D] Downloading \(infoURLiCloud.relativePath)")
                infoURLiCloud.downloadFromiCloud{_,_, infoURL in
                    sem.signal()
                }
                //Info already  exist
                sem.wait()
                return readInfo(at: infoURL)
            }else{
                print("[D] Not exist \(infoURLiCloud.relativePath)")
                //Info does not exist anywhere.
                if FileManager.default.fileExists(atPath: fileURL.relativePath){
                    //File exist locally!
                    var info = getInfo(at: fileURL)
                    var infoJSON = try? JSONEncoder().encode(info)
                    try? infoJSON?.write(to: infoURL)
                }
                return readInfo(at: infoURL)
            }
        }else{
            //infoExist
            return readInfo(at: infoURL)
        }
        
        
    }
    
    func readInfo(at url:URL) -> TrackInfo{
        if let data = try? Data(contentsOf: url){
            if let ti = try? JSONDecoder().decode(TrackInfo.self, from: data){
                return ti
            }
        }
        return TrackInfo(duration: 0, filesize: 0, factor: 0)
        
    }
    
    func getInfo(at url:URL) -> TrackInfo{
        let asset = AVURLAsset(url: url, options: nil)
        let length = Int64(asset.duration.seconds)
        let size = (try? Int64(Data(contentsOf: url).count) ) ?? 0
        let factor = Double(length)/Double(size)
        return TrackInfo(duration: length, filesize: size, factor: factor)
        
    }
    
    func downloadFromiCloud(result: @escaping (Bool,Double,URL?)->Void){
        DispatchQueue.main.async {
            
            
            print("[UPD] downloading \(self)")
            if self.lastPathComponent.contains(".icloud") {
                
                
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ timer in
                    var res = try? self.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
                    var status = res?.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey]
                    print("[UPD] checikim \(self)")
                    if status == nil{
                        timer.invalidate()
                        result (true,1.0, self.noiCloud())
                        return
                    }else{
                        print("[UPD] inp \(self)")
                        
                    }
                    //result(false,0.5,nil)
                    
                }
                try? FileManager.default.startDownloadingUbiquitousItem(at: self )
            }else{
                print("[UPD] \(self)")
                result (true,1.0, self)
            }
        }
    }
    
    func noiCloud()->URL{
        if self.lastPathComponent.contains(".icloud"){
            var url = self
            var nlpc = url.lastPathComponent
            nlpc = nlpc.replacingOccurrences(of:".icloud", with: "")
            url = url.deletingLastPathComponent().appendingPathComponent( "\(nlpc.dropFirst(1))")
            return url
        }else{
            return self
        }
    }
    func infoURL()->URL{
        if self.lastPathComponent.contains(".mp3"){
            var url = self
            var nlpc = url.lastPathComponent
            nlpc = nlpc.replacingOccurrences(of:".mp3", with: ".info")
            url = url.deletingLastPathComponent().appendingPathComponent( "\(nlpc)")
            return url
        }else{
            return self
        }
    }
    func infotxtURL()->URL{
        if !self.lastPathComponent.contains(".txt"){
            var url = self
            url = url.deletingLastPathComponent().appendingPathComponent( "info.txt")
            return url
        }else{
            return self
        }
    }
    func coverURL()->URL{
        if !self.lastPathComponent.contains(".jpg"){
            var url = self
            url = url.deletingLastPathComponent().appendingPathComponent( "cover.jpg")
            return url
        }else{
            return self
        }
    }
    func iCloud()->URL{
        if (self.lastPathComponent.contains(".icloud")) {return self}
        if self.lastPathComponent.contains(".mp3") || self.lastPathComponent.contains(".info"){
            var url = self
            var nlpc = ".\(url.lastPathComponent).icloud"
            url = url.deletingLastPathComponent().appendingPathComponent("\(nlpc)")
            return url
        }else{
            return self
        }
    }
   
}
