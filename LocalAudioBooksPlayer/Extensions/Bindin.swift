//
//  Bindin.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 04/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI

extension Binding{
    init(_ source: Binding<Value?>,_ defaultValue:Value){
        if source.wrappedValue == nil {
            source.wrappedValue = defaultValue
        }
        self.init(source)!
    }
}

extension Binding {
    func safeBinding<T>(defaultValue: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>.init {
            self.wrappedValue ?? defaultValue
        } set: { newValue in
            self.wrappedValue = newValue
        }
    }
    
    static func instant<T>(value: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>.init {  value } set: { _ in  }
    }
}

