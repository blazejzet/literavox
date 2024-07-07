//
//  MonthlyCloudSubscription.swift
//  MyBooks
//
//  Created by Dawid Jenczewski on 09/03/2021.
//  Copyright © 2021 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

@objc class MonthlyCloudSubscription : NSObject,ObservableObject{
    
    @Published var priceString = "1$"
    @Published  var isSubscribe = true
    private static let productID = "pl.asuri.edu.LiteraVOX.monthly"
    
    override init(){
        super.init()
        self.getPriceString()
        self.getSubscribtionState()
        
    }
    
    func getPriceString() {
        
        
        SwiftyStoreKit.retrieveProductsInfo([MonthlyCloudSubscription.productID], completion: {
            
            result in
            if let product = result.retrievedProducts.first{
                
                self.priceString = product.localizedPrice ?? "1$"
                
            }else if let invalidProductId = result.invalidProductIDs.first {
                
                print("Invalid product identifier: \(invalidProductId)")
                
            }else {
                
                print("Error: \(result.error)")
            }
            
        })
    }
    
    
    func purchaseProduct(completion: @escaping (Bool)->Void){
        DispatchQueue.global().async {
            if !self.isSubscribe {
            
                SwiftyStoreKit.purchaseProduct(MonthlyCloudSubscription.productID,quantity: 1,atomically: true){
                result in
                switch result {
                case .success(let product):
                    // fetch content from your server, then:
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                    print("Purchase Success: \(product.productId)")
                    self.isSubscribe = true
                    completion(true)
                case .error(let error):
                    
                    switch error.code {
                    case .unknown: print("Unknown error. Please contact support")
                    case .clientInvalid: print("Not allowed to make the payment")
                    case .paymentCancelled: break
                    case .paymentInvalid: print("The purchase identifier was invalid")
                    case .paymentNotAllowed: print("The device is not allowed to make the payment")
                    case .storeProductNotAvailable: print("The product is not available in the current storefront")
                    case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                    case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        
                    default: print((error as NSError).localizedDescription)
                    }
                    completion(false)
                }
            }
            }else{
                print("Product is subscribed")
                completion(true)
            }
        }
        
    }
    
    func fetch(){
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData):
                //let encryptedReceipt = receiptData.base64EncodedString(options: [])
                
                print("Fetch receipt success")
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
    }
    
    func getSubscribtionState(){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "da961b2b72eb4587a9e35e31d35e0565")
        
        let localReceipt = SwiftyStoreKit.localReceiptData
        if(localReceipt != nil){
            print("localReceipt != nil")
            SwiftyStoreKit.verifyReceipt(using: appleValidator,forceRefresh: false) { result in
                switch result {
                case .success(let receipt):
                    print("Verify receipt success")
                    let subcsriptionResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: MonthlyCloudSubscription.productID, inReceipt: receipt)
                    
                    switch subcsriptionResult{
                    case .purchased(let expiryDate, let receiptItems):
                        print("Product is valid until \(expiryDate)")
                        self.isSubscribe = true
                    case .expired(let expiryDate, let receiptItems):
                        print("Product is expired since \(expiryDate)")
                        self.isSubscribe = false
                    case .notPurchased:
                        print("This product has never been purchased")
                        self.isSubscribe = false
                    }                    
                case .error(let error):
                    print("Verify receipt failed: \(error)")
                }
                //completion()
            }
        }
    }
        
    static func getState(cb: @escaping ()->Void){
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "da961b2b72eb4587a9e35e31d35e0565")
        
        let localReceipt = SwiftyStoreKit.localReceiptData
        if(localReceipt != nil){
            SwiftyStoreKit.verifyReceipt(using: appleValidator,forceRefresh: false) { result in
                switch result {
                case .success(let receipt):
                    let subcsriptionResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: MonthlyCloudSubscription.productID, inReceipt: receipt)
                    
                    switch subcsriptionResult{
                    case .purchased(let expiryDate, let receiptItems):
                        cb()
                    case .expired(let expiryDate, let receiptItems):
                        break
                    case .notPurchased:
                        break
                    }
                case .error(let error):
                    print("Verify receipt failed: \(error)")
                }
                //completion()
            }
        }
        
    }
    
}
