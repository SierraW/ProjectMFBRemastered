//
//  CurrencyListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-20.
//

import SwiftUI

struct CurrencyListView: View {
    @EnvironmentObject var currencyData: CurrencyData
    @State var isLoading = false
    
    var onSelect: (Int) -> Void
    
    func refresh(_ newValue: String? = nil) {
        let _ = currencyData.fetchAll()
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                if (currencyData.currencies.isEmpty) {
                    List([0], id: \.self) { val in
                        Text("No Data")
                    }
                    .refreshable {
                        withAnimation {
                            refresh()
                        }
                    }
                } else {
                    List(currencyData.currencies.indices, id: \.self) { index in
                        CurrencyIdentityView(currency: currencyData.currencies[index])
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(index)
                        }
                    }
                    .refreshable {
                        withAnimation {
                            refresh()
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Currency")
        .onAppear {
            refresh()
        }
    }
}
