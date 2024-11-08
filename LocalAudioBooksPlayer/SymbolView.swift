//
//  SymbolView.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI

struct SymbolView: View {
    var mark:Mark
    var body: some View {
        ZStack{
            
            Rectangle().foregroundColor(mark.color).frame(width:30, height:30).cornerRadius(40.0)
            Image(systemName: mark.icon).foregroundColor(.white)
            
        }.frame(width:30, height:30)
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(mark: Mark(icon: "book", color: .red))
    }
}
