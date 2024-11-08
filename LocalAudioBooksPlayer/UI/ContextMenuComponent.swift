//
//  ContextMenuComponent.swift
//  privmx-pocket-2-ios
//
//  Created by Blazej Zyglarski on 08/11/2022.
//

import Foundation
import SwiftUI





struct MXContextMenuComponent: View {

    @StateObject var menumodel: MXContextMenuModel
   
    @State var offset:CGFloat = 500.0
    @State var opacity:CGFloat = 0.0
    
    var body: some View {
        
       
                
        ZStack{
            if menumodel.isShown {
                Rectangle().foregroundColor(.black).opacity(opacity).onTapGesture {
                    withAnimation{
                        offset=500.0
                        opacity = 0.0
                    }
                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false){ _ in
                        MXContextMenuModel.global.hideContextMenu()
                    }
                }
                VStack{
                    
                    Spacer(minLength: 150)
                    if let c = menumodel.content {
                        
                            c.cornerRadius(10)
                            
                            .background{Rectangle().foregroundColor(.white).cornerRadius(10)}
                            .onAppear{
                                 
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                              
                            
                        }.offset(y:offset)
                    }
                    if let cs = menumodel.contentsheet {
                        
                            cs.cornerRadius(10)
                            
                            .background{Rectangle().foregroundColor(.white).cornerRadius(10)}
                            .onAppear{
                                 
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                              
                            
                        }.offset(y:offset)
                    }
                }.cornerRadius(10)
                 .padding(10)
                 .padding([.bottom],30)
            
                 
                 .onAppear{
                     withAnimation{
                         offset=0.0
                         opacity = 0.3
                     }
                 }.onDisappear{
                     withAnimation{
                         offset=500.0
                         opacity = 0.0
                     }
                 }.onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification)){ _ in
                     withAnimation{
                         offset=0.0
                     }
                 }
                 .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)){ notification in
                     guard let userInfo = notification.userInfo,
                            let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                                
                     withAnimation{
                         offset = -keyboardRect.height
                     }
                 }
                    
            }
                
        }.sheet(isPresented: $menumodel.isShownSheet){
            
            menumodel.contentsheet ?? AnyView(EmptyView())
        }.ignoresSafeArea()
       
    }
}
