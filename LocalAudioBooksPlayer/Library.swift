//
//  Library.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 29/01/2023.
//  Copyright © 2023 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class Library:ObservableObject{
    static let global = Library()
    @Published var availableProviders: [Provider.Type] =  [LocalProvider.self]

    private var savedProviders = [String]()
    private var providersStorage = UserDefaults.standard
    var booksInfoStorage = BooksInfoStorage()
    @Published var lastPlayedBookId: String?
    
    @Published var providers = [Provider]()
    
    var books:[Book2]{
        providers.flatMap{$0.books}.sorted{$0.title < $1.title}
    }
    func cbooks(_ prov:Provider?)->[Book2]{
        if prov != nil {
            
            print("\(providers.filter{$0.instancename == prov!.instancename}.flatMap{$0.books}.sorted{$0.title < $1.title}.count)")
            return providers.filter{$0.instancename == prov!.instancename}.flatMap{$0.books}.sorted{$0.title < $1.title}

        }else{
            return books
        }
    }
    
    
    func reload(){
        for p in providers{
            p.loadBooks()
        }
    }
    
    func removeProvider(providerCode:String){
        for i in 0 ..< providers.count{
            var p = providers[i]
            if p.providercode == providerCode{
                providers.remove(at: i)
                self.savedProviders.remove(at: i)
                self.providersStorage.set(self.savedProviders, forKey: "sources4")
                self.providersStorage.synchronize()
                return
            }
        }
        
        
    }
    
    func saveLastPlayedBook(_ id: String? = nil){
        self.objectWillChange.send()
        self.providersStorage.set(id, forKey: "lastPlayed")
        self.lastPlayedBookId = id
    }
    
    func getLastPlayedBookID(){
        self.objectWillChange.send()
        self.lastPlayedBookId =  self.providersStorage.string(forKey: "lastPlayed")
    }
    
    var aqueue:DispatchQueue
    init(){
        self.aqueue =  DispatchQueue(label: "file_analysing_queue")
    
        self.savedProviders = self.providersStorage.array(forKey: "sources4") as? [String] ?? []
        for providerCode in self.savedProviders{
            if let providerInfo = self.providersStorage.dictionary(forKey: providerCode) as? [String:Any]
            {
                var providerType = providerInfo["providerType"] as? String ?? ""
                if providerType == "simpleServer"{
                    let newProvider = LocalProvider(dict: providerInfo)
                    newProvider.loadBooks()
                    DispatchQueue.main.async {
                        self.providers.append(newProvider)
                    }
                }
            }
        }
    }
    
    func download(track:Track2, cb:@escaping (URL)->Void ){
        if FileManager.default.fileExists(atPath: track.url!.absoluteString){cb(track.url!)}else{
            track.url!.iCloud().downloadFromiCloud { success, error , url in
                if success, let url = url{
                    cb(url)
                }else{
                    print(error)
                }
                
            }
        }
    }
    
    var inProgress:Bool{
        self.providers.filter{($0 as! LocalProvider).inProgress}.count > 0
    }
    func addLocalProvider(name: String, url: URL, bd:Data,icon: String, color:UIColor,category: String ){
        
        let pro = LocalProvider(mark: Mark(icon: icon, color: Color(color)), server: url.absoluteString, name: name)
         
        pro.url = url
        
        DispatchQueue.main.async {
            
            self.providers.append(pro)
        }
        
        pro.loadBooks()
        var r:CGFloat = 0,g:CGFloat = 0,b:CGFloat = 0,o:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &o)
        let rgbDict = ["r":r,"g":g,"b":b,"o":o] as Dictionary<String,CGFloat>
        let dict = ["name":name,"bd":bd,"server":pro.server,"pcode":pro.server,"category":category,"icon":icon,"background":rgbDict, "providerType" : ProviderTypes.simpleServer] as Dictionary<String,Any>
        
        self.providersStorage.set(dict, forKey: pro.providercode)
        self.savedProviders.append(pro.providercode)
        self.providersStorage.set(self.savedProviders, forKey: "sources4")
        self.providersStorage.synchronize()
            
        
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
