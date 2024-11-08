//
//  ContextMenuContent.swift
//  privmx-pocket-2-ios
//
//  Created by Blazej Zyglarski on 10/11/2022.
//

import Foundation
import SwiftUI


struct ContextMenuContent : View {

    var label:String
    var description:String
    var details:String?
    var buttons:[MXContextButton]
    var preview: AnyView?
    
    var body: some View {
        
        VStack(spacing:0){
                
                
                
                SheetHeaderComponentWithoutButton(label: label, description: description)

                
                let buttonsnotclassic = buttons.filter{!$0.classic}
            
                if (buttonsnotclassic.count>0){
                    ForEach( 0 ..< buttonsnotclassic.count ) { index in
                        
                        
                        VStack{
                            
                            buttonsnotclassic[index].body
                                .padding([.top],20)
                                .padding([.bottom],10)
                                .padding([.trailing,.leading],20)
                            Rectangle()
                                .frame(height: 1.0)
                                .foregroundColor(.gray)
                            
                            
                        }
                        
                    }
                }
             
                let butonsclassic = buttons.filter{$0.classic}
                if (butonsclassic.count>0){
                    VStack(spacing:0){
                        ForEach( 0 ..< butonsclassic.count ) { index in
                            
                            
                            VStack{
                                
                                butonsclassic[index].body
                                    .padding([.top],20)
                                    .padding([.trailing,.leading],20)
                                
                                
                            }
                            
                            
                            
                        }
                    }.padding([.bottom],20)
                    .background(Color.black)
                }
            }
                
    }
}
