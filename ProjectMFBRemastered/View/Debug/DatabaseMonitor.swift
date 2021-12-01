//
//  DatabaseMonitor.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI
import CoreData

struct DatabaseMonitor: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var bill = [Bill]()
    @State var billItem = [BillItem]()
    @State var billPayment = [BillPayment]()
    @State var billTotal = [BillTotal]()
    @State var payable = [Payable]()
    @State var ratedPayable = [RatedPayable]()
    
    @State var paymentMethod = "No Set"
    @State var currency = "No Set"
    @State var tag = "No Set"
    @State var transaction = "No Set"
    @State var transactionReport = "No Set"
    
    @State var user = "No Set"
    
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Bill")
                    Spacer()
                    Text("\(bill.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        bill = result
                    } catch {
                        print("Fetch error")
                    }
                }
                
                HStack {
                    Text("Bill Item")
                    Spacer()
                    Text("\(billItem.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<BillItem> = BillItem.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        billItem = result
                    } catch {
                        print("Fetch error")
                    }
                }
                
                HStack {
                    Text("Bill Payment")
                    Spacer()
                    Text("\(billPayment.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<BillPayment> = BillPayment.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        billPayment = result
                    } catch {
                        print("Fetch error")
                    }
                }

                HStack {
                    Text("Bill Total")
                    Spacer()
                    Text("\(billTotal.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<BillTotal> = BillTotal.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        billTotal = result
                    } catch {
                        print("Fetch error")
                    }
                }

                HStack {
                    Text("Payable")
                    Spacer()
                    Text("\(payable.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<Payable> = Payable.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        payable = result
                    } catch {
                        print("Fetch error")
                    }
                }

                HStack {
                    Text("Rated Payable")
                    Spacer()
                    Text("\(ratedPayable.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<RatedPayable> = RatedPayable.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        ratedPayable = result
                    } catch {
                        print("Fetch error")
                    }
                }
                
                Button(role: .destructive) {
                    for object in bill {
                        viewContext.delete(object)
                    }
                    save()
                } label: {
                    Text("Clear Bill")
                }
                
                Button(role: .destructive) {
                    for object in billItem {
                        viewContext.delete(object)
                    }
                    save()
                } label: {
                    Text("Clear Bill Item")
                }
                
                Button(role: .destructive) {
                    for object in billPayment {
                        viewContext.delete(object)
                    }
                    save()
                } label: {
                    Text("Clear Bill Payment")
                }
            } header: {
                Text("Functional Layer")
            }
            
            Section {
                HStack {
                    Text("Payment Method")
                    Spacer()
                    Text(paymentMethod)
                }
                
                HStack {
                    Text("Currency")
                    Spacer()
                    Text(currency)
                }
                
                HStack {
                    Text("Tag")
                    Spacer()
                    Text(tag)
                }
                
                HStack {
                    Text("Transaction")
                    Spacer()
                    Text(transaction)
                }
                
                HStack {
                    Text("Transaction Report")
                    Spacer()
                    Text(transactionReport)
                }
            } header: {
                Text("Core Layer")
            }
            
            Section {
                HStack {
                    Text("User")
                    Spacer()
                    Text(user)
                }
            } header: {
                Text("Essential Layer")
            }
        }
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            
        }
    }
}

struct DatabaseMonitor_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseMonitor()
    }
}
