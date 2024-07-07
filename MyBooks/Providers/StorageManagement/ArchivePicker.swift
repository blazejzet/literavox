//
//  ArchivePicker.swift
//  AudiobookTestProject
//
//  Created by Damian Skarżyński on 11/03/2020.
//  Copyright © 2020 damian.skarzynski. All rights reserved.
//

import SwiftUI
import MobileCoreServices

enum PickerType{
    case archive, cover
}

struct ArchivePicker : UIViewControllerRepresentable {
    
    class Coordinator : NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate{
        
        let parent : ArchivePicker
        
        init(_ parent: ArchivePicker ){
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
            if let url = urls.first{
                parent.url = url
                parent.callback(url)
            }
//            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var url: URL?
    var pickerType: PickerType = .archive
    var callback: (URL) -> ()?
    
    func makeCoordinator() -> ArchivePicker.Coordinator {
        return ArchivePicker.Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ArchivePicker>) -> UIDocumentPickerViewController {
        
        var types: [String] = []
        
        switch self.pickerType{
            
            case .archive:
                types = [String(kUTTypeArchive)]
                break
                
            case .cover:
                
                types = [String(kUTTypeImage)]
                break
            
        
        }
        let picker = UIDocumentPickerViewController(documentTypes: types, in: .open)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<ArchivePicker>) {
    }
    
}
