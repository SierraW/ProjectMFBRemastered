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
    
    @State var paymentMethod = [PaymentMethod]()
    @State var currency = [Currency]()
    @State var tag = [Tag]()
    @State var transaction = [Transaction]()
    @State var billReport = [BillReport]()
    
    @State var user = [User]()
    
    
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
                .contextMenu {
                    Button(role: .destructive) {
                        for object in bill {
                            viewContext.delete(object)
                        }
                        save()
                    } label: {
                        Text("Clear Bill")
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
                .contextMenu {
                    Button(role: .destructive) {
                        for object in billItem {
                            viewContext.delete(object)
                        }
                        save()
                    } label: {
                        Text("Clear Bill Item")
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
                .contextMenu {
                    Button(role: .destructive) {
                        for object in billPayment {
                            viewContext.delete(object)
                        }
                        save()
                    } label: {
                        Text("Clear Bill Payment")
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
            } header: {
                Text("Functional Layer")
            }
            
            Section {
                HStack {
                    Text("Payment Method")
                    Spacer()
                    Text("\(paymentMethod.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<PaymentMethod> = PaymentMethod.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        paymentMethod = result
                    } catch {
                        print("Fetch error")
                    }
                }
                
                HStack {
                    Text("Currency")
                    Spacer()
                    Text("\(currency.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        currency = result
                    } catch {
                        print("Fetch error")
                    }
                }
                
                HStack {
                    Text("Tag")
                    Spacer()
                    Text("\(tag.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        tag = result
                    } catch {
                        print("Fetch error")
                    }
                }
                
                HStack {
                    Text("Transaction")
                    Spacer()
                    Text("\(transaction.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        transaction = result
                    } catch {
                        print("Fetch error")
                    }
                }
                .contextMenu {
                    Button(role: .destructive) {
                        for object in transaction {
                            viewContext.delete(object)
                        }
                        save()
                    } label: {
                        Text("Clear")
                    }

                }
                
                HStack {
                    Text("Transaction Report")
                    Spacer()
                    Text("\(billReport.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<BillReport> = BillReport.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        billReport = result
                    } catch {
                        print("Fetch error")
                    }
                }
                .contextMenu {
                    Button(role: .destructive) {
                        for object in billReport {
                            viewContext.delete(object)
                        }
                        save()
                    } label: {
                        Text("Clear")
                    }

                }
            } header: {
                Text("Core Layer")
            }
            
            Section {
                HStack {
                    Text("User")
                    Spacer()
                    Text("\(user.count)")
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        user = result
                    } catch {
                        print("Fetch error")
                    }
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
