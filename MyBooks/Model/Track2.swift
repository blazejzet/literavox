//
//  Track2.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 29/01/2023.
//  Copyright © 2023 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI

enum TrackState:Codable{
    case online,downloading, offline
}

struct Track2:Codable,Hashable{
    static func == (lhs: Track2, rhs: Track2) -> Bool {
        lhs.filename == rhs.filename
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.filename!)
    }
    var filename:String?
    var length:Int?
    var start:Int?
    var num:Int?
    var url:URL?
    var bookmarksTags = [Bookmark2]()
    var bookmarks:Int? = 0
    var percent : Double
    var state: TrackState = .online
    mutating func setPercent(_ d:Double){
        self.percent = d
        GlobalPlayer.shared?.trackChanged()
    }
    mutating func setState(_ d:TrackState){
        self.state = d
        GlobalPlayer.shared?.trackChanged()
    }
}
