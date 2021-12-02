//
//  BillSplitByAmountWizardView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-26.
//

import SwiftUI

struct BillSplitByAmountWizardView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    
    @State var numberOfBillsString = "0"
    
    @State var submitting = false
    
    var numberOfBills: Int? {
        Int(numberOfBillsString)
    }
    
    var total: Decimal {
        return data.total
    }
    
    var amountPerBill: Decimal {
        if let numberOfBills = numberOfBills {
            return (total / Decimal(numberOfBills)).rounded(toPlaces: 2)
        }
        return 0
    }
    
    var disableSubmitButton: Bool {
        if let numberOfBills = numberOfBills {
            return !(numberOfBills > 1 && numberOfBills < 20)
        }
        return true
    }
    
    var body: some View {
        VStack {
            Text("Split By Total")
                .font(.headline)
                .padding(.top)
            Form {
                Section {
                    HStack {
                        Text("# Of Bills")
                            .bold()
                            .foregroundColor(.gray)
                        DecimalField(placeholder: "Number Here", textAlignment: .center, limitToPlaces: 0, value: $numberOfBillsString) { _ in
                            if let numberOfBills = numberOfBills {
                                data.splitByAmountSubmit(splitCount: numberOfBills)
                            }
                        }
                        .onAppear(perform: {
                            numberOfBillsString = "\(data.size)"
                        })
                        .font(.title)
                        .foregroundColor(.blue)
                    }
                } footer: {
                    Text("limit: 1 < n < 20")
                }
                
                Section {
                    if disableSubmitButton{
                        Text("Empty...")
                            .foregroundColor(.gray)
                    } else if let numberOfBills = numberOfBills {
                        ForEach(1...numberOfBills, id: \.self) { index in
                            HStack {
                                Text("SBA Bill #\(index)")
                                Spacer()
                                Text(appData.majorCurrency.toStringRepresentation)
                                Text(amountPerBill.toStringRepresentation)
                            }
                        }
                    }
                } header: {
                    Text("Split Result Preview")
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Text("Total")
                        .bold()
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(total.toStringRepresentation)
                }
                .font(.title3)
                HStack {
                    Spacer()
                    Button {
                        submitting = true
                        if let numberOfBills = numberOfBills {
                            data.splitByAmountSubmit(splitCount: numberOfBills)
                        }
                        submitting = false
                    } label: {
                        Text("Split")
                            .foregroundColor(.white)
                            .font(.title3)
                            .frame(width: 90)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 5)
                            .background(RoundedRectangle(cornerRadius: 15).foregroundColor(disableSubmitButton ? .gray : .blue))
                        
                    }
                    .disabled(disableSubmitButton || submitting)
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
