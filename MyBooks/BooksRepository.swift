//
//  BooksRepository.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation

@MainActor
class BooksRepository: NSObject,ObservableObject{
    
    static let global = BooksRepository()
    
    @Published var availableProviders: [Provider.Type] =  [LocalProvider.self]
    
    @Published var providers = [Provider]()
    
    private var savedProviders: [String] = []
    var booksInfoStorage = BooksInfoStorage()
    private let productID = "pl.asuri.edu.LiteraVOX.monthly"
    
    private var isLoading = false
    private var updateIsNeeded = false
    
    private var providersToUpdate: [BooksProvider] = []
    
    var downloadingTracks : [Track] = []
    @Published var books = [Book]()
    @Published var types = [Type]()
    
    @ObservedObject @objc var monthlySubsription = MonthlyCloudSubscription()
    @Published var subscribeObserver = false
    private var observer : NSKeyValueObservation?
    private var providersStorage = UserDefaults.standard
    override init() {
        
        super.init()
        //print (type(of: avai))
        //TODO: initialize cloud providr
        /*var pro3 = CloudServerProvider(destination:self)
         pro3.symbol = CloudServerProvider.Symbols.cloud
         pro3.loadBooks(of:"category"){
         self.providers.append(pro3)
         }*/
        //self.getMonthlyAccess(){
        
        
//        
//        self.observer = observe(\.self.monthlySubsription.isSubscribe, options: [.old,.new]){
//            object, change in
//            DispatchQueue.main.async {
//                self.subscribeObserver = change.newValue ?? false
//            }
//            self.updateProviders()
//            
//        }
//        self.savedProviders = self.providersStorage.array(forKey: "sources4") as? [String] ?? []
//        self.loadProviders()
//        self.loadLocalBookInfo()
//        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedValue(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        
        //}
        
    }
    
    
    public func booksAppend(_ books:[Book]){
        self.objectWillChange.send()
        self.books.append(contentsOf:books)
    }
    
    
    func removeProvider(providerCode: String){
        
        self.books = self.books.filter{$0.providercode != providerCode}
        self.providers = self.providers.filter{$0.providercode != providerCode}
        self.providersStorage.removeObject(forKey: providerCode)
        let index = self.savedProviders.firstIndex(where: {$0 == providerCode})
        if index != nil{
            self.savedProviders.remove(at: index!)
        }
        self.providersStorage.set(self.savedProviders, forKey: "sources4")
        self.updateProviders()
    }
    func loadData(for book:Book2, cl:(()->Void)?){
        Task{
            for provider in providers{
//                if provider.provides(_book: book) {
//                    provider.loadBookData(book: book, cl: cl)
//                }
            }
        }
    }
    func updateBook(_ book:Book){
        self.objectWillChange.send()
    }
    func getLocalFile(for track:Track2, inBook book:Book, downloading: inout Bool, shouldBeDownloaded: Bool,cb:@escaping ((URL,Track)->Void)){
        
        
    }
    
    func loadLocalBookInfo(){
       
            for book in self.books {
                DispatchQueue.main.async {
                    book.favourite = self.booksInfoStorage.favValue(bookID: book.id.uuidString ?? "")
                    book.read = self.booksInfoStorage.readValue(bookID: book.id.uuidString ?? "")
                    self.objectWillChange.send()
                }
            }
            
            
    }
//
//    func loadProviders(){
//        self.isLoading = true
//        print("load providers")
//
//        //deleting removed providers or icloud providers if is not subsribing
//
//
//
//        var onlyEnabledProviders = self.savedProviders
////        //usuniecie wszystkich cloud providerow jesli nie subskrybujemy
////        onlyEnabledProviders.removeAll(where: {
////            let providerInfo = self.providersStorage.dictionary(forKey: $0) ?? nil
////            if providerInfo != nil{
////                if (providerInfo!["providerType"] as? String ?? "") == ProviderTypes.cloudKit
////                    && !self.monthlySubsription.isSubscribe{
////                    print("delete")
////                    return true
////                }
////            }
////
////            return false
////        })
//
////        //usun providery ktore nie sa na liscie odblokowanych
//       for provider in self.providers{
////
////            if !onlyEnabledProviders.contains(provider.providercode){
////                self.books.array = self.books.array.filter{$0.providercode != provider.providercode}
////                self.providers = self.providers.filter{$0.providercode != provider.providercode}
////            }else{
//
//
//                   self.providersToUpdate.append(provider)
//
////            }
//      }
////
//        //aktualizuj wszystkie z listy
//        if !onlyEnabledProviders.isEmpty{
//            for providerCode in onlyEnabledProviders{
//                let providerInfo = self.providersStorage.dictionary(forKey: providerCode) ?? nil
//                if providerInfo != nil{
//                    let providerType = providerInfo!["providerType"] as? String ?? ""
//                    if providerType == "simpleServer"{
//                        let pro = LocalStorageProvider(dict: providerInfo! as! [String:Any])
//                        DispatchQueue.main.async {
//                            self.providers.append(pro)
//
//                        }
//
//                        pro.loadBooks(of:""){ success in
//
//                        }
//                    }
//
//                }else{
//
//                    print("Error with get providerInfo from UserDefaults")
//
//                }
//            }
//        }else {
//            self.isLoading = false
//        }
//    }
    
    
    func noAddedLibraries() -> Bool{
        return (self.providersStorage.array(forKey: "sources4") as? [String] ?? []).isEmpty
    }
    
    
    func updateProviders(){
        
        self.updateIsNeeded = true
        
        if(!self.isLoading){
            
            print("updating Providers")
            self.isLoading = true
            self.updateIsNeeded = false
            
           // self.loadProviders()
            
            
        }
        
    }
    
    func getSavedProvidercodeList()-> [String]{
        return self.savedProviders
    }
    
    
    func getCountOfProviders(ofType type: String) -> Int{
        var counter = 0
        
        for providerCode in self.savedProviders{
            if let providerInfo = self.providersStorage.dictionary(forKey: providerCode) ?? nil{
                let providerType = providerInfo["providerType"] as? String ?? ""
                if providerType == type{
                    counter += 1
                }
            }
        }
        
        return counter
    }
    
    @objc func changedValue(notification:Notification){
        print("[DEBUG:Cloud:KVO] changes in structure")
        self.updateProviders()
    }
    
    public func saveBookmarkData(for workDir: URL) -> Data?{
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withoutImplicitSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)

            // save in UserDefaults
            return bookmarkData
        } catch {
            print("Failed to save bookmark data for \(workDir)", error)
        }
        return nil
    }
    
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
////
////  File.swift
////  MyBooks
////
////  Created by Blazej Zyglarski on 03/05/2020.
////  Copyright © 2020 Blazej Zyglarski. All rights reserved.
////
//
//import Foundation
//import SwiftUI
//import AVFoundation
//
//@MainActor
//class BooksRepository: NSObject,ObservableObject{
//
//    static let global = BooksRepository()
//
//    @Published var availableProviders: [BooksProvider.Type] =  [LocalStorageProvider.self, iCloudProvider.self]
//
//    @Published var providers = [BooksProvider]()
//
//    private var savedProviders: [String] = []
//    var booksInfoStorage = BooksInfoStorage()
//    private let productID = "pl.asuri.edu.LiteraVOX.monthly"
//
//    private var isLoading = false
//    private var updateIsNeeded = false
//
//    private var providersToUpdate: [BooksProvider] = []
//
//    var downloadingTracks : [Track] = []
//    @Published var books = [Book]()
//    @Published var types = [Type]()
//
//    @ObservedObject @objc var monthlySubsription = MonthlyCloudSubscription()
//    @Published var subscribeObserver = false
//    private var observer : NSKeyValueObservation?
//    private var providersStorage = UserDefaults.standard
//    override init() {
//
//        super.init()
//        //print (type(of: avai))
//        //TODO: initialize cloud providr
//        /*var pro3 = CloudServerProvider(destination:self)
//         pro3.symbol = CloudServerProvider.Symbols.cloud
//         pro3.loadBooks(of:"category"){
//         self.providers.append(pro3)
//         }*/
//        //self.getMonthlyAccess(){
//
//
////
////        self.observer = observe(\.self.monthlySubsription.isSubscribe, options: [.old,.new]){
////            object, change in
////            DispatchQueue.main.async {
////                self.subscribeObserver = change.newValue ?? false
////            }
////            self.updateProviders()
////
////        }
//        self.savedProviders = self.providersStorage.array(forKey: "sources4") as? [String] ?? []
//        self.loadProviders()
//        self.loadLocalBookInfo()
//
//
//        NotificationCenter.default.addObserver(self, selector: #selector(changedValue(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
//
//        //}
//
//    }
//    func addLocalProvider(name: String, url: URL, bd:Data,icon: String, color:UIColor,category: String ){
//
//        let pro = LocalStorageProvider()
//        pro.server = url.absoluteString
//        pro.name = name
//        pro.url = url
//        pro.symbol = Mark(icon: icon, color: Color(color))
//        DispatchQueue.main.async {
//
//            self.providers.append(pro)
//        }
//        pro.loadBooks(of:category) {
//            result in
//            if(result){
//
//                var r:CGFloat = 0,g:CGFloat = 0,b:CGFloat = 0,o:CGFloat = 0
//                color.getRed(&r, green: &g, blue: &b, alpha: &o)
//                let rgbDict = ["r":r,"g":g,"b":b,"o":o] as Dictionary<String,CGFloat>
//                let dict = ["name":name,"bd":bd,"server":pro.server,"category":category,"icon":icon,"background":rgbDict, "providerType" : ProviderTypes.simpleServer] as Dictionary<String,Any>
//
//                self.providersStorage.set(dict, forKey: pro.providercode)
//                self.savedProviders.append(pro.providercode)
//                self.providersStorage.set(self.savedProviders, forKey: "sources4")
//                //self.providersStorage.persist()
//           }
//        }
//    }
//
//    public func booksAppend(_ books:[Book]){
//        self.objectWillChange.send()
//        self.books.append(contentsOf:books)
//    }
//
//
//    func removeProvider(providerCode: String){
//
//        self.books = self.books.filter{$0.providercode != providerCode}
//        self.providers = self.providers.filter{$0.providercode != providerCode}
//        self.providersStorage.removeObject(forKey: providerCode)
//        let index = self.savedProviders.firstIndex(where: {$0 == providerCode})
//        if index != nil{
//            self.savedProviders.remove(at: index!)
//        }
//        self.providersStorage.set(self.savedProviders, forKey: "sources4")
//        self.updateProviders()
//    }
//    func loadData(for book:Book, cl:(()->Void)?){
//        Task{
//            for provider in providers{
//                if provider.provides(_book: book) {
//                    provider.loadBookData(book: book, cl: cl)
//                }
//            }
//        }
//    }
//    func updateBook(_ book:Book){
//        self.objectWillChange.send()
//    }
//    func getLocalFile(for track:Track, inBook book:Book, downloading: inout Bool, shouldBeDownloaded: Bool,cb:@escaping ((URL,Track)->Void)){
//        print("[D] Trying to download \(track.filename)");
//        for provider in providers{
//            if provider.provides(_book: book) {
//
//                print("[D][3] getLocalFile")
//                provider.getLocalFile(for:track, inBook:book){ url in
//                    self.downloadingTracks.removeAll(where: {$0 == track})
//                    cb(url,track)
//
//                }
////
////                do{
////                    let documentsURL = try
////                        FileManager.default.url(for: .documentDirectory,
////                                                in: .userDomainMask,
////                                                appropriateFor: nil,
////                                                create: false).appendingPathComponent(book.id.uuidString ?? "")
////
////                    if !FileManager.default.fileExists(atPath: documentsURL.path) {
////                        try? FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
////                    }
////
////                    let localfilename = provider.getFileHash(for: track)//track.getFileHash()
////                    let localURL = documentsURL.appendingPathComponent(localfilename)
////
////
////                    print (localURL.path)
////                    if(!FileManager.default.fileExists(atPath: localURL.path)){
////                        if(shouldBeDownloaded){
////                            downloading = true
////
////                            if !self.downloadingTracks.contains(track){
////                                self.downloadingTracks.append(track)
////                                provider.getLocalFile(for:track, inBook:book, saveTo: localURL){
////                                    print("[GlobalPlayer] pobrany został plik \(localURL)")
////                                    //downloading = false
////                                    self.downloadingTracks.removeAll(where: {$0 == track})
////                                    cb(localURL,track)
////
////                                }
////                            }
////                        }
////
////                    }else{
////                        downloading = false
////                        cb(localURL,track)
////                    }
////                }catch{
////                    print("get localURL error")
////                }
//            }
//        }
//
//    }
//
//    func loadLocalBookInfo(){
//
//            for book in self.books {
//                DispatchQueue.main.async {
//                    book.favourite = self.booksInfoStorage.favValue(bookID: book.id.uuidString ?? "")
//                    book.read = self.booksInfoStorage.readValue(bookID: book.id.uuidString ?? "")
//                    self.objectWillChange.send()
//                }
//            }
//
//
//    }
//
//    func loadProviders(){
//        self.isLoading = true
//        print("load providers")
//
//        //deleting removed providers or icloud providers if is not subsribing
//
//
//
//        var onlyEnabledProviders = self.savedProviders
////        //usuniecie wszystkich cloud providerow jesli nie subskrybujemy
////        onlyEnabledProviders.removeAll(where: {
////            let providerInfo = self.providersStorage.dictionary(forKey: $0) ?? nil
////            if providerInfo != nil{
////                if (providerInfo!["providerType"] as? String ?? "") == ProviderTypes.cloudKit
////                    && !self.monthlySubsription.isSubscribe{
////                    print("delete")
////                    return true
////                }
////            }
////
////            return false
////        })
//
////        //usun providery ktore nie sa na liscie odblokowanych
//       for provider in self.providers{
////
////            if !onlyEnabledProviders.contains(provider.providercode){
////                self.books.array = self.books.array.filter{$0.providercode != provider.providercode}
////                self.providers = self.providers.filter{$0.providercode != provider.providercode}
////            }else{
//
//
//                   self.providersToUpdate.append(provider)
//
////            }
//      }
////
//        //aktualizuj wszystkie z listy
//        if !onlyEnabledProviders.isEmpty{
//            for providerCode in onlyEnabledProviders{
//                let providerInfo = self.providersStorage.dictionary(forKey: providerCode) ?? nil
//                if providerInfo != nil{
//                    let providerType = providerInfo!["providerType"] as? String ?? ""
//                    if providerType == "simpleServer"{
//                        let pro = LocalStorageProvider(dict: providerInfo! as! [String:Any])
//                        DispatchQueue.main.async {
//                            self.providers.append(pro)
//
//                        }
//
//                        pro.loadBooks(of:""){ success in
//
//                        }
//                    }
//
//                }else{
//
//                    print("Error with get providerInfo from UserDefaults")
//
//                }
//            }
//        }else {
//            self.isLoading = false
//        }
//    }
//
//
//    func noAddedLibraries() -> Bool{
//        return (self.providersStorage.array(forKey: "sources4") as? [String] ?? []).isEmpty
//    }
//
//
//    func updateProviders(){
//
//        self.updateIsNeeded = true
//
//        if(!self.isLoading){
//
//            print("updating Providers")
//            self.isLoading = true
//            self.updateIsNeeded = false
//
//            self.loadProviders()
//
//
//        }
//
//    }
//
//    func getSavedProvidercodeList()-> [String]{
//        return self.savedProviders
//    }
//
//    func saveLastPlayedBook(_ id: String? = nil){
//        self.providersStorage.set(id, forKey: "lastPlayed")
//    }
//
//    func getLastPlayedBookID()->String?{
//        return self.providersStorage.string(forKey: "lastPlayed")
//    }
//
//    func getCountOfProviders(ofType type: String) -> Int{
//        var counter = 0
//
//        for providerCode in self.savedProviders{
//            if let providerInfo = self.providersStorage.dictionary(forKey: providerCode) ?? nil{
//                let providerType = providerInfo["providerType"] as? String ?? ""
//                if providerType == type{
//                    counter += 1
//                }
//            }
//        }
//
//        return counter
//    }
//
//    @objc func changedValue(notification:Notification){
//        print("[DEBUG:Cloud:KVO] changes in structure")
//        self.updateProviders()
//    }
//
//    public func saveBookmarkData(for workDir: URL) -> Data?{
//        do {
//            let bookmarkData = try workDir.bookmarkData(options: .withoutImplicitSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
//
//            // save in UserDefaults
//            return bookmarkData
//        } catch {
//            print("Failed to save bookmark data for \(workDir)", error)
//        }
//        return nil
//    }
//
//}
//
//
//
