//
//  SheetHeaderComponent.swift
//  privmx-pocket-2-ios
//
//  Created by Blazej Zyglarski on 08/12/2022.
//

import Foundation


import SwiftUI

struct SheetHeaderComponent<Content>: View where Content: View{
    var label:String
    var description:String
    
    
    let buttonAction:(()->Void)?
    @Binding var active:Bool
    
    var buttonContent: (() -> Content)?
     @State private var pushed:Bool = false
    var body: some View {
        HStack{
            VStack{
                HStack{
                    Text(LocalizedStringKey(label))
                    Spacer()
                    
                }
                HStack{
                    Text(LocalizedStringKey(description))
                    Spacer()
                    
                }
            }
            Spacer()
            if let bc = buttonAction{
                VStack{
                    Button(action: {
                        if !pushed {
                            bc()
                            pushed=true
                        }
                    }){
                        if !pushed {
                            buttonContent?()
                        }else{
                            HStack{
                                CircularIndicator()
                            }.padding(5)
                        }
                    }
                    .padding(5).background(RoundedRectangle(cornerRadius: 15.0)
                        .foregroundColor(.gray)
                    )
                    .disabled(!active).opacity(active ? 1.0 : 0.3)
                    
                }
            }
        }.padding(20)
            .background{Rectangle().foregroundColor(.white)}

        
    }
}





struct SheetHeaderComponentWithoutButton: View{
    var label:String
    var description:String
    
    
    var body: some View {
        HStack{
            VStack{
                HStack{
                    Text(LocalizedStringKey(label))
                    Spacer()
                    
                }
                HStack{
                    Text(LocalizedStringKey(description))
                    Spacer()
                    
                }
            }
            
        }.padding(20)
            .background{Rectangle().foregroundColor(.white)}

        
    }
}
