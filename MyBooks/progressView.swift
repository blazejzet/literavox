//
//  progressView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 04/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI

struct ProgressView: View {
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    
    @Binding var percent:Double
    var body: some View {
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//      //  if (colorScheme == .dark){
//             .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//             .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
            
      //  }
      ///
        return ZStack{
            GeometryReader { geometry in
                Rectangle().frame(width:5, height:   geometry.size.height)
                    .foregroundColor(.background).cornerRadius(3)
                
                Rectangle().cornerRadius(3).frame(width:5, height: CGFloat(self.percent ??  0) * geometry.size.height )
                    .foregroundColor(.foreground)
            
                
            }
        }.frame(width: 5.0).padding(.vertical, -6)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(percent: .constant(0.1))
    }
}
