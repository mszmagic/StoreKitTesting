//
//  ContentView.swift
//  StoreKitTesting
//
//  Created by Shunzhe Ma on 2020/09/05.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @State var statusString: String
    @State var availableProducts: [SKProduct]
    
    var storeHelper = StorePurchaseHelper(productIDs: ["virtualCatFood", "virtualCatHouse", "dailyVirtualCatFood"])
    
    var body: some View {
        
        Text(statusString)
        
        Button(action: {
            self.storeHelper.delegate = self
            self.storeHelper.requestProductsInfo()
        }, label: {
            Text("製品情報を要求")
        })
        
        List(self.availableProducts, id: \.self) { product in
            VStack(alignment: .leading, spacing: nil, content: {
                Text(product.productIdentifier)
                    .font(.headline)
                Text(String(describing: product.price))
                Button(action: {
                    self.storeHelper.purchase(item: product)
                }, label: {
                    Text("購入")
                })
            })
        }
        
    }
    
}

extension ContentView: StorePurchaseHelperDelegate {
    func receivedProductsInfo(products: [SKProduct]) {
        self.availableProducts = products
    }
    
    func purchaseSuccessful(forProductID: String) {
        statusString = "\(forProductID)の購入が成功しました"
    }
    
    func purchaseFailed(forProductID: String, reason: String?) {
        statusString = "\(forProductID)の購入が失敗しました \(String(describing: reason))"
    }
    
    func purchaseRestored(forProductID: String) {
        statusString = "\(forProductID)の購入ステータスが復元されました"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(statusString: "", availableProducts: [])
    }
}
