//
//  FileManager.swift
//  MyBooks
//
//  Created by Damian Skarżyński on 09/09/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation

extension FileManager{
    static var documentsDirectoryURL: URL{
        self.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
}
