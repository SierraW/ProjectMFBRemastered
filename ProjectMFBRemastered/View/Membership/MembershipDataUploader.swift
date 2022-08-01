//
//  MembershipDataUploader.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-24.
//

import SwiftUI
import CoreData

struct MembershipDataUploader: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appData: MembershipAppData
    
    @State var tags: [Tag] = []
    @State var payable: [Payable] = []
    @State var ratedPayable: [RatedPayable] = []
    @State var currency = [Currency]()
    @State var paymentMethod = [PaymentMethod]()
    
    @State var uploadStarted = false
    @State var tagUploaded: Bool = false
    @State var payableUploaded = false
    @State var ratedPayableUploaded = false
    @State var currencyUploaded = false
    @State var paymentMethodUploaded = false
    
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Tag")
                    Spacer()
                    if uploadStarted {
                        if tagUploaded {
                            Text("Uploaded")
                                .foregroundColor(.green)
                        } else {
                            ProgressView()
                        }
                    } else {
                        Text("\(tags.count)")
                    }
                }
                .onAppear {
                    let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
                    do {
                        let result = try viewContext.fetch(fetchRequest)
                        tags = result
                    } catch {
                        print("Fetch error")
                    }
                }
                HStack {
                    Text("Payable")
                    Spacer()
                    if uploadStarted {
                        if payableUploaded {
                            Text("Uploaded")
                                .foregroundColor(.green)
                        } else {
                            ProgressView()
                        }
                    } else {
                        Text("\(payable.count)")
                    }
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
                    if uploadStarted {
                        if ratedPayableUploaded {
                            Text("Uploaded")
                                .foregroundColor(.green)
                        } else {
                            ProgressView()
                        }
                    } else {
                        Text("\(ratedPayable.count)")
                    }
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
                HStack {
                    Text("Currency")
                    Spacer()
                    if uploadStarted {
                        if currencyUploaded {
                            Text("Uploaded")
                                .foregroundColor(.green)
                        } else {
                            ProgressView()
                        }
                    } else {
                        Text("\(currency.count)")
                    }
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
                    Text("Payment Method")
                    Spacer()
                    if uploadStarted {
                        if paymentMethodUploaded {
                            Text("Uploaded")
                                .foregroundColor(.green)
                        } else {
                            ProgressView()
                        }
                    } else {
                        Text("\(paymentMethod.count)")
                    }
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
            } header: {
                Text("Local Data")
            }
            
            Section {
                Button {
                    uploadStarted = true
                    Task {
                        // tag
                        let tagController = AuthenticatedDataAccessController<MFBRoom>(appData.authentication)
                        for tag in tags.filter({ tag in
                            tag.is_room
                        }) {
                            let mfbRoom = MFBRoom(id: 0, name: tag.name ?? "err", starred: tag.starred, disabled: false, dateCreated: "", lastModified: "")
                            let _ = await tagController.post(to: tagController.baseUrl + "room/admin/create/", with: mfbRoom.toDict, using: .POST)
                        }
                        await MainActor.run {
                            tagUploaded = true
                        }
                        
                        //payable
                        let itemController = AuthenticatedDataAccessController<MFBItem>(appData.authentication)
                        for payableItem in payable {
                            let mfbItem = MFBItem(id: 0, name: payableItem.tag?.name ?? "err", autoAddOnCheckout: false, value: (payableItem.amount ?? 0) as Decimal, isRate: false, isNegativeEffectOnBill: payableItem.is_deposit, tags: [], effectiveTags: [], starred: false, disabled: false, dateCreated: "", lastModified: "")
                            let _ = await itemController.post(to: itemController.baseUrl + "item/admin/", with: mfbItem.toDict, using: .POST)
                        }
                        await MainActor.run {
                            payableUploaded = true
                        }
                        
                        //rated payable
                        for ratedPayableItem in ratedPayable {
                            let mfbItem = MFBItem(id: 0, name: ratedPayableItem.tag?.name ?? "err", autoAddOnCheckout: false, value: (ratedPayableItem.rate ?? 0) as Decimal, isRate: true, isNegativeEffectOnBill: ratedPayableItem.is_deposit, tags: [], effectiveTags: [], starred: false, disabled: false, dateCreated: "", lastModified: "")
                            let _ = await itemController.post(to: itemController.baseUrl + "item/admin/", with: mfbItem.toDict, using: .POST)
                        }
                        await MainActor.run {
                            ratedPayableUploaded = true
                        }
                        
                        //currency
                        for item in currency {
                            let mfbCurrency = MFBCurrency(name: item.name ?? "err", prefix: item.prefix ?? "err", symbol: item.symbol ?? "err", isMajorCurrency: item.is_major, exchangeRate: "\(item.rate ?? 0)", id: 0, starred: false, disabled: false, dateCreated: "", lastModified: "")
                            let _ = await itemController.post(to: itemController.baseUrl + "currency/admin/", with: mfbCurrency.toDict, using: .POST)
                        }
                        await MainActor.run {
                            currencyUploaded = true
                        }
                        
                        //payment method
                        for item in paymentMethod {
                            let mfbPaymentMethod = MFBPaymentMethod(id: 0, name: item.name ?? "err", assignedCurrency: nil, autoAddItemTag: nil, starred: true, disabled: false, dateCreated: "", lastModified: "")
                            let _ = await itemController.post(to: itemController.baseUrl + "paymentMethod/admin/create/", with: mfbPaymentMethod.toDict, using: .POST)
                        }
                        await MainActor.run {
                            paymentMethodUploaded = true
                        }
                    }
                    
                    
                    
                } label: {
                    Text("Upload")
                }
            }
        }
    }
}

struct MembershipDataUploader_Previews: PreviewProvider {
    static var previews: some View {
        MembershipDataUploader()
    }
}
