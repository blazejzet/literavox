//
//  Int.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 05/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation

extension Int {
    func toTimeString()->String{
        
        var l0m = ""
        if (self / 60 < 10) {
            l0m = "0"
        }
        var l0s = ""
        if (self % 60 < 10) {
            l0s = "0"
        }
        var minutes = self / 60
        let seconds = self % 60
        
        if minutes<60{
            return "\(l0m)\(minutes):\(l0s)\(seconds)"
        }else{
            var l0g = ""
            if (minutes / 60 < 10) {
                l0g = "0"
            }
            var hours = minutes / 60
            minutes = minutes % 60
            return "\(l0g)\(hours):\(l0m)\(minutes):\(l0s)\(seconds)"
        }
    }
}
