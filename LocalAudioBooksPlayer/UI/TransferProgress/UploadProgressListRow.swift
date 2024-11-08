//
//  UploadProgressListRow.swift
//  LocalAudioBooksPlayer
//
//  Created by Damian Skarżyński on 16/09/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
import Reachability

struct UploadProgressListRow: View {
    @Environment (\.colorScheme) var colorScheme
    @Binding var wifiIsReachable: Bool
    var body: some View {
        //self.getWifiReachability()
        
        var mainColor = Color.init(red: 0.3, green: 0.3, blue: 0.3)
        var backColor = Color.init(red: 0.95, green: 0.95, blue: 0.95)
        if (colorScheme == .dark){
            backColor = Color.init(red: 0.3, green: 0.3, blue: 0.3)
            mainColor = Color.init(red: 0.8, green: 0.8, blue: 0.8)
            
        }
        return HStack{
            VStack(alignment: .leading) {

                Text("\(bookUploadCell.bookTitle)").font(.system(size: 20, weight: .bold))
                Text("\(bookUploadCell.bookAuthor)")
                
                
                
            }
            Spacer()
            ZStack{
                ProgressIndicator
                if bookUploadCell.percent <= 0.999999999999 {
                    Text("\(Int(bookUploadCell.percent*100.0))%").font(.system(size: 13))
                }
            }
            
            //if(self.bookUploadCell.paused){
                
                Button(action: {
                    withAnimation{
                        self.bookUploadCell.paused.toggle()
                        if self.bookUploadCell.paused{
                            self.bookUploadCell.pauseUpload()
                        }else{
                            self.bookUploadCell.startUpload()
                        }
                    }
                }){
                    if(self.bookUploadCell.paused){
                        Text("Start")//.transition(.asymmetric(insertion: .flipFromBottom, removal: .move(edge: .bottom)))
                    }else{
                        Text("Pause")//.transition(.asymmetric(insertion: .flipFromBottom, removal: .move(edge: .bottom)))
                    }
                }.foregroundColor(mainColor).padding(8).frame(width: 65, height: 35, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(backColor))
                .disabled(!self.wifiIsReachable).clipped()
            //}
        }
            
        .contentShape(Rectangle())
        .padding(.vertical,10).animation(.easeInOut)
    }
    
    var ProgressIndicator: some View{
        ZStack {
//            if self.firebaseBookUpload.percent != 1{
            
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.3)
                .foregroundColor(Color.primary)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.bookUploadCell.percent, 1.0)))
//                .trim(from: 0.0, to: CGFloat(min(self.tmp, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.primary)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            if self.bookUploadCell.percent > 0.999999999999{
                Image(systemName: "checkmark").font(Font.title.bold()).frame(width: 30, height: 30).animation(.spring())
            }
            
            //                Text(String(format: "%.0f %%", min(self.firebaseBookUpload.percent, 1.0)*100.0))
            //                    .font(.largeTitle)
            //                    .bold()
        }.frame(minWidth: 0, maxWidth: 40, minHeight: 0, maxHeight: 40, alignment: .trailing)
    }
    
    
    
//    func getWifiReachability(){
//        self.reachability?.whenReachable = {
//            reachability in
//            if reachability.connection == .wifi{
//                print("wifi is reachable")
//                self.wifiIsReachable = true
//            }else{
//                self.wifiIsReachable = false
//            }
//        }
//        self.reachability?.whenUnreachable = {
//            reachability in
//            self.wifiIsReachable = false
//        }
//        try? self.reachability?.startNotifier()
//    }
    
}

//struct UploaderListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            
//
//        }
//
//    }
//}


