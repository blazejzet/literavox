//
//  MXContextButton.swift
//  privmx-pocket-2-ios
//
//  Created by Blazej Zyglarski on 08/11/2022.
//

import Foundation
import SwiftUI


enum MXContextButtonType{
    case action, normal
}

struct MXContextButton{
     
    var emoji : String?
    var text : String
    var classic = false
    
    var type : MXContextButtonType? = .normal
    var action:()->Void
  
    var body: some View {
        
        Button(action: {
            action()
            
        }) {
            HStack{
                if (classic){
                    Spacer()
                }
                
                Text(LocalizedStringKey( text)).foregroundColor( classic ? .white : .black)
                Spacer()
                
            }
        }.padding(classic ?  15.0 : 0.0)
        .background{
            Rectangle().foregroundColor( classic ? ((type == .action) ? .black : .gray) : .clear).cornerRadius(5.0)
        }
        
    }
}

