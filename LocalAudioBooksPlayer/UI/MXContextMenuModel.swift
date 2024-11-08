//
//  MXContextMenuModel.swift
//  privmx-pocket-2-ios
//
//  Created by Blazej Zyglarski on 08/11/2022.
//

import Foundation


import SwiftUI

    class MXContextMenuModel: ObservableObject{
        
        static var global = MXContextMenuModel()
        
        @Published var isShown = false
        @Published var isShownSheet = false
        @Published var text = ""
        @Published var content: ContextMenuContent?
        @Published var contentsheet: AnyView?
        
        var sh : ((Bool)->Void)?
        
        public func showContextMenu(content:ContextMenuContent, sh: @escaping ((Bool)->Void)){
            self.sh = sh
         
                sh(true)
                isShown = true
            
            self.contentsheet = nil
            self.content = content
        }
        public func showContextMenu(content:ContextMenuContent){
            
                isShown = true
                isShownSheet = false
                self.contentsheet = nil
                self.content = content
        }
        public func showContextSheet(content:AnyView){
            isShown = false
            isShownSheet = true
            self.content = nil
            self.contentsheet = content
        }
        public func showCompactContextSheet(content:AnyView){
            isShown = true
            isShownSheet = false
            self.content = nil
            self.contentsheet = content
        }
        
        public func hideContextMenu(){
            
            
            sh?(false)
            self.isShown=false
            self.isShownSheet=false
            self.content = nil
            self.contentsheet = nil
            self.sh=nil
            
        }
    }

