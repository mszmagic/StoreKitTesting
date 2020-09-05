//
//  StorePurchaseHelper.swift
//  StoreKitTesting
//
//  Created by Shunzhe Ma on 2020/09/05.
//

import Foundation
import StoreKit

public protocol StorePurchaseHelperDelegate {
    func receivedProductsInfo(products: [SKProduct])
    
    // 購入が成功しました
    func purchaseSuccessful(forProductID: String)
    
    // 購入が失敗しました
    func purchaseFailed(forProductID: String, reason: String?)
    
    // ユーザーは以前にこのアイテムを購入しています
    func purchaseRestored(forProductID: String)
}

public class StorePurchaseHelper : NSObject {
    
    public var delegate: StorePurchaseHelperDelegate?
    
    var productIDs: Set<String>
    
    init(productIDs: Set<String>) {
        self.productIDs = productIDs
    }
    
    public func requestProductsInfo() {
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    public func purchase(item: SKProduct) {
        // ユーザーが支払い可能かを確認してください
        guard SKPaymentQueue.canMakePayments() else {
            self.delegate?.purchaseFailed(forProductID: item.productIdentifier, reason: "ユーザーが支払いをすることができません")
            return
        }
        let payment = SKPayment(product: item)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
}

extension StorePurchaseHelper: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let itemID = transaction.payment.productIdentifier
            switch transaction.transactionState {
                case .purchasing:
                    break
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    self.delegate?.purchaseSuccessful(forProductID: itemID)
                case .failed:
                    self.delegate?.purchaseFailed(forProductID: itemID, reason: transaction.error?.localizedDescription)
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    self.delegate?.purchaseRestored(forProductID: itemID)
                case .deferred:
                    break
                @unknown default:
                    break
            }
        }
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let availableProducts = response.products
        self.delegate?.receivedProductsInfo(products: availableProducts)
    }
    
    
}
