//
//  ObservableArray.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import Combine

class ObservableArray<T: ObservableObject>: ObservableObject {

    @Published var array:[T] = []
    var cancellables = [AnyCancellable]()

    init(array: [T]) {
        self.array = array

    }

    func append(_ array:[T]){
           //print("[PROV] Adding \(array.count) of \(T.self)")
           self.array.append(contentsOf: array)
       }
    
    
    func refresh(_ e: (T)->Bool){
        let array2 = array as! [T]
        array2.forEach({
            if e($0){
                let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
                self.cancellables.append(c)
            }
        })
    }
    func append(_ object:T){
           //print("[PROV] Adding \(array.count) of \(T.self)")
           self.array.append(object)
       }
    
    func observeChildrenChanges<T: ObservableObject>() -> ObservableArray<T> {
        let array2 = array as! [T]
        array2.forEach({
            let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })

            // Important: You have to keep the returned value allocated,
            // otherwise the sink subscription gets cancelled
            self.cancellables.append(c)
        })
        return self as! ObservableArray<T>
    }


}
