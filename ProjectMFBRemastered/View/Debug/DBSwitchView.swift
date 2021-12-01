//
//  DBSwitchView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct DBSwitchView: View {
    @State var viewState: BillData.ViewState = .bill
    
    var body: some View {
        switch viewState {
        case .bill:
            billView
        case .originalBillReview:
            originalBillReviewView
        default:
            splitByPayableView
        }
    }
    
    var billView: some View {
        VStack {
            Text("Bill View")
            Button {
                viewState = .bill
            } label: {
                Text("Bi")
            }
            Button {
                viewState = .originalBillReview
            } label: {
                Text("ORi")
            }
            Button {
                viewState = .splitByPayable
            } label: {
                Text("sbp")
            }
        }
        .navigationTitle("billView")
    }
    
    var originalBillReviewView: some View {
        VStack {
            Text("originalBillReviewView")
            
            Button {
                viewState = .bill
            } label: {
                Text("Bi")
            }
            Button {
                viewState = .originalBillReview
            } label: {
                Text("ORi")
            }
            Button {
                viewState = .splitByPayable
            } label: {
                Text("sbp")
            }
        }
        .navigationTitle("originalBillReviewView")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewState = .bill
                } label: {
                    Text("Discard")
                }

            }
        }
    }
    
    var splitByPayableView: some View {
        VStack {
            Text("splitByPayableView")
            Button {
                viewState = .bill
            } label: {
                Text("Bi")
            }
            Button {
                viewState = .originalBillReview
            } label: {
                Text("ORi")
            }
            Button {
                viewState = .splitByPayable
            } label: {
                Text("sbp")
            }
        }
    }
}

struct DBSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        DBSwitchView()
    }
}
