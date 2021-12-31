//
//  TESEReport.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-26.
//

import SwiftUI

struct TESEReportView: View {
    var report: BillReport
    
    var bills: [Bill] {
        if let bills = report.bills?.allObjects as? [Bill] {
            return bills.sorted(by: {($0.openTimestamp ?? Date()) < ($1.openTimestamp ?? Date()) })
        }
        return []
    }
    
    @State var showCopiedAlert = false
    
    var combinedIncome: [String: Decimal] {
        var result = [String: Decimal]()
        for bill in bills {
            if let transactions = bill.transactions?.allObjects as? [Transaction] {
                for transaction in transactions {
                    if let paymentMethod = transaction.paymentMethod, let currency = transaction.currency, let amount = transaction.amount as Decimal? {
                        let name = "\(paymentMethod.toStringRepresentation) - \(currency.toStringRepresentation)"
                        result[name] = (result[name] ?? 0) + amount
                    }
                }
            }
        }
        return result
    }
    
    var allPayable: [Payable: Int] {
        func retrievePayable(from bill: Bill, payableAmountDict: inout [Payable: Int]) {
            if let items = bill.items?.allObjects as? [BillItem] {
                for item in items {
                    if let payable = item.payable {
                        payableAmountDict[payable] = (payableAmountDict[payable] ?? 0) + Int(item.count)
                    }
                }
            }
            
            if let children = bill.children?.allObjects as? [Bill] {
                for child in children {
                    retrievePayable(from: child, payableAmountDict: &payableAmountDict)
                }
            }
        }
        
        var result = [Payable: Int]()
        for bill in bills {
            retrievePayable(from: bill, payableAmountDict: &result)
        }
        return result
    }
    
    var allRatedPayable: [RatedPayable: Int] {
        func retrieveRatedPayable(from bill: Bill, ratedPayableAmountDict: inout [RatedPayable: Int]) {
            if let items = bill.items?.allObjects as? [BillItem] {
                for item in items {
                    if let ratedPayable = item.ratedPayable {
                        ratedPayableAmountDict[ratedPayable] = (ratedPayableAmountDict[ratedPayable] ?? 0) + Int(item.count)
                    }
                }
            }
            
            if let children = bill.children?.allObjects as? [Bill] {
                for child in children {
                    retrieveRatedPayable(from: child, ratedPayableAmountDict: &ratedPayableAmountDict)
                }
            }
        }
        
        var result = [RatedPayable: Int]()
        for bill in bills {
            retrieveRatedPayable(from: bill, ratedPayableAmountDict: &result)
        }
        return result
    }
    
    var allAssociatedTag: [Tag: Int] {
        var result = [Tag: Int]()
        bills.forEach({
            if let tag = $0.associatedTag {
                result[tag] = (result[tag] ?? 0) + 1
            }
        })
        return result
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("From")
                    Spacer()
                    if let bill = bills.first, let openDate = bill.openTimestamp {
                        Text(openDate.toStringRepresentation)
                    }
                }
                HStack {
                    Text("To")
                    Spacer()
                    if let bill = bills.last, let openDate = bill.openTimestamp {
                        Text(openDate.toStringRepresentation)
                    }
                }
                HStack {
                    Text("Number of Bills")
                    Spacer()
                    Text("\(bills.count)")
                }
            }
            Section {
                ForEach(combinedIncome.keys.sorted()) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        Text(combinedIncome[key]?.toStringRepresentation ?? "err")
                    }
                }
            } header: {
                Text("Combined Income")
            }
            Section {
                ForEach(allPayable.keys.sorted(by: {
                    if allPayable[$0] == allPayable[$1] {
                        return $0.toStringRepresentation < $1.toStringRepresentation
                    } else {
                        return allPayable[$0] ?? 0 > allPayable[$1] ?? 0
                    }
                })) { payable in
                    HStack {
                        Text(payable.toStringRepresentation)
                        Spacer()
                        Text("\(allPayable[payable] ?? 0)")
                    }
                }
            } header: {
                Text("Best-selling products")
            }
            
            Section {
                ForEach(allRatedPayable.keys.sorted(by: {
                    if allRatedPayable[$0] == allRatedPayable[$1] {
                        return $0.toStringRepresentation < $1.toStringRepresentation
                    } else {
                        return allRatedPayable[$0] ?? 0 > allRatedPayable[$1] ?? 0
                    }
                })) { ratedPayable in
                    HStack {
                        Text(ratedPayable.toStringRepresentation)
                        Spacer()
                        Text("\(allRatedPayable[ratedPayable] ?? 0)")
                    }
                }
            } header: {
                Text("Top rated products")
            }
            
            Section {
                ForEach(allAssociatedTag.keys.sorted(by: {
                    if allAssociatedTag[$0] == allAssociatedTag[$1] {
                        return $0.toStringRepresentation < $1.toStringRepresentation
                    } else {
                        return allAssociatedTag[$0] ?? 0 > allAssociatedTag[$1] ?? 0
                    }
                })) { tag in
                    HStack {
                        Text(tag.toStringRepresentation)
                        Spacer()
                        Text("\(allAssociatedTag[tag] ?? 0)")
                    }
                }
            } header: {
                Text("Top tags")
            } footer: {
                HStack {
                    Spacer()
                    Text("MFB x TE Statistic Engine™")
                        .foregroundColor(.gray)
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Export") {
                    var customString = "COMBINED TOTAL:\n"
                    combinedIncome.keys.sorted().forEach({customString.append("\($0) \(combinedIncome[$0]?.toStringRepresentation ?? "0.00")\n")})
                    customString.append(contentsOf: "MFB x TESE FORMAL REPORT\n")
                    let controller = BillReportPrintingController(bills: bills)
                    let _ = controller
                        .setHeaderCustomContent(customString)
                        .addPrinter(BillHeadlinePrinter())
                        .addPrinter(BillSubBillPrinter())
                        .addPrinter(BillTransactionPrinter())
                    UIPasteboard.general.setValue(controller.toStringRepresentation, forPasteboardType: "public.plain-text")
                    showCopiedAlert.toggle()
                }
            }
        })
        .navigationBarTitle("TESE™ Report")
        .alert("Report Copied", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
