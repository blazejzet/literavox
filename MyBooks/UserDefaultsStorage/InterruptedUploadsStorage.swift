//
//  InterruptedUpdates.swift
//  MyBooks
//
//  Created by Dawid Jenczewski on 16/02/2021.
//  Copyright © 2021 Blazej Zyglarski. All rights reserved.
//
//dla kazdej ksiazki szukamy tytulu oraz autora w cloudkicie wykorzystujac bookid
//
import Foundation

class InterruptedUploadsStorage {
    var uploadsStorage : [String]? = nil
    
    init(){
        self.uploadsStorage = UserDefaults.standard.array(forKey: "interruptedUploads") as? [String]
    }
    
    func addValue(value val: String){
        if(self.uploadsStorage == nil){
            self.uploadsStorage = []
        }
        self.uploadsStorage?.append(val)
        self.updateStorage()
    }
    
    func removeValue(value val: String){
        if(self.uploadsStorage?.isEmpty ?? true){
            print("Interrupted uploads storage is empty")
        }else{
            self.uploadsStorage?.removeAll(where: {$0 == val})
        }
        self.updateStorage()
    }
    
    func updateStorage(){
        UserDefaults.standard.setValue(self.uploadsStorage, forKey: "interruptedUploads")
    }
}
