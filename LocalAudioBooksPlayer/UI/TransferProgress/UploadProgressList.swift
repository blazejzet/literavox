//
//  UploadProgressList.swift
//  LocalAudioBooksPlayer
//
//  Created by Damian Skarżyński on 16/09/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI

struct UploadProgressList: View {
    @EnvironmentObject var repo: BooksRepository
    @ObservedObject var networkMonitor = NetworkMonitor()
    var body: some View {

        //NavigationView{
            VStack(alignment: .leading){
                HStack{
                    Text("Uploads").font(.largeTitle).bold()
                    Spacer()
                    if(!self.networkMonitor.isConnectedToWifi){
                        Image(systemName: "wifi.slash").font(.system(size:22))
                    }
                }
                Text("Here is the list of your uploads").font(.system(size: 22,weight:.light)).padding(0)
                
                Spacer()
                
        }.padding(30)
    }
}

struct UploadProgressList_Previews: PreviewProvider {
    static var previews: some View {
        UploadProgressList()
    }
}
