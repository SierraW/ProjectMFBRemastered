//
//  BillViewV2.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-21.
//

import SwiftUI

struct BillViewV2: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    @State var showDescriptionEditor = false
    @State var additionalDescription = ""
    
    @State var selectedBillItems = [BillItem: Int]()
    @State var selectedBill: Bill? = nil
    
    @State var timer: Timer? = nil
    @State var animationTimer: Timer? = nil
    @State var rotateLeft: Bool? = nil
    @State var timeElapsed: TimeInterval? = nil
    
    var ableToSubmit: Bool {
        data.total == 0 && data.children.first(where: {$0.proceedBalance == nil}) == nil
    }
    
    var onExit: () -> Void
    
    
    var body: some View {
        if data.viewState == .splitByAmount {
            BillSplitByAmountView {
                onExit()
            }
            .environmentObject(appData)
            .environmentObject(data)
        } else if data.viewState == .originalBillReview {
            BillTransactionView(splitMode: .amountOnly) {
                onExit()
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(appData)
            .environmentObject(data)
        } else if data.viewState == .completed {
            completedView
        } else {
            billSectionView
                .sheet(isPresented: $showDescriptionEditor) {
                    VStack {
                        HStack {
                            Image(systemName: "chevron.down.circle")
                            Text("Leave a message about this bill...")
                                .bold()
                            Spacer()
                        }
                        .foregroundColor(.gray)
                        .padding(.top)
                        .padding(.horizontal)
                        .onTapGesture {
                            showDescriptionEditor.toggle()
                        }
                        TextEditor(text: $additionalDescription)
                            .frame(idealHeight: 250)
                            .padding()
                        Spacer()
                        Button {
                            showDescriptionEditor.toggle()
                        } label: {
                            Text("Close")
                                .bold()
                                .padding(.bottom, 5)
                        }
                    }
                }

        }
    }
    
    var billSectionView: some View {
        GeometryReader { geometry in
            VStack (spacing: 0) {
                Form {
                    Section {
                        ForEach(data.items, id:\.smartId) { item in
                            BillItemViewCellV2(selection: $selectedBillItems, billItem: item)
                                .environmentObject(appData)
                                .environmentObject(data)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    addToCart(item)
                                }
                        }
                        NavigationLink {
                            BillItemShoppingView(onSubmit: { payableDict, ratedPayableDict in
                                data.addItems(payableDict: payableDict, ratedPayableDict: ratedPayableDict)
                            })
                                .environment(\.managedObjectContext, viewContext)
                                .environmentObject(appData)
                                .environmentObject(data)
                                .navigationTitle("Select items...")
                            
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                Text("Item")
                                Spacer()
                            }
                            .foregroundColor(.blue)
                        }
                    } footer: {
                        HStack {
                            Button {
                                toggleTimer()
                            } label: {
                                HStack {
                                    Image(systemName: timer == nil ? "play.slash.fill" : "play.fill")
                                    if let timeElapsed = timeElapsed {
                                        Text("Time elapsed: \(timeElapsed.toStringRepresentation)")
                                            
                                    } else {
                                        Text("Time elapsed: Loading...")
                                    }
                                }
                            }
                            Spacer()
                            if !ableToSubmit {
                                Button(role: .destructive) {
                                    data.setInactive()
                                    onExit()
                                } label: {
                                    Text("Hold")
                                        .bold()
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                Divider()
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ScrollView(.horizontal) {
                            HStack {
                                Button {
                                    createNewBill()
                                } label: {
                                    BillWidget()
                                }
                                .rotationEffect(Angle(degrees: rotateLeft == nil ? 0 : rotateLeft! ? -3 : 3))
                                .animation(Animation.linear.speed(2), value: rotateLeft)
                                .contextMenu {
                                    Text("To create a new bill, select item from above.")
                                }
                                .padding(.horizontal, 7)
                                ForEach(data.children.sorted()) { bill in
                                    let billData = BillData(context: viewContext, bill: bill)
                                    Button {
                                        if selectedBillItems.isEmpty {
                                            selectedBill = bill
                                        } else {
                                            addToBill(billData)
                                        }
                                    } label: {
                                        BillWidget(empty: false)
                                            .environmentObject(appData)
                                            .environmentObject(billData)
                                    }
                                    .rotationEffect(.degrees(rotateLeft == nil ? 0 : rotateLeft! ? -3 : 3))
                                    .animation(Animation.linear.speed(2), value: rotateLeft)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            removeSubBill(bill)
                                            reload()
                                        } label: {
                                            Text("Remove Bill")
                                        }
                                    }
                                    NavigationLink("", tag: bill, selection: $selectedBill) {
                                        BillTransactionView(splitMode: .none) {
                                            onExit()
                                        }
                                        .environment(\.managedObjectContext, viewContext)
                                        .environmentObject(appData)
                                        .environmentObject(billData)
                                    }
                                    .hidden()
                                    
                                }
                            }
                            .frame(height: 110)
                        }
                        Divider()
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(appData.majorCurrency.toStringRepresentation) \(data.total.toStringRepresentation)")
                                    .frame(alignment: .center)
                                    .padding(.top, 2.5)
                                Button {
                                    showDescriptionEditor.toggle()
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                Spacer()
                            }
                            .font(.system(size: 17))
                            Group {
                                if !selectedBillItems.isEmpty {
                                    Button {
                                        clearCart()
                                    } label: {
                                        Text("Clear Selection")
                                            .foregroundColor(.red)
                                    }
                                } else if ableToSubmit {
                                    Button {
                                        data.submitBill(appData)
                                        presentationMode.wrappedValue.dismiss()
                                        onExit()
                                    } label: {
                                        Text("Submit")
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                } else if data.children.isEmpty {
                                    Button {
                                        data.originalBillSubmit()
                                    } label: {
                                        Text("Pay")
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Bills (HOLD)")
                                    }
                                    .foregroundColor(.red)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            for bill in data.children {
                                                removeSubBill(bill)
                                            }
                                            reload()
                                        } label: {
                                            Text("Confirm Clear All Bills")
                                        }
                                    }
                                }
                            }
                            .frame(width: 150, height: 50)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray5)))
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 120)
                    .padding(.vertical, 7)
                }
                
            }
            .onAppear {
                toggleTimer()
            }
        }
    }
    
    var completedView: some View {
        VStack {
            Text("This bill is completed")
            Button("Start new bill") {
                data.setInactive()
                onExit()
            }
        }
    }
    
    func toggleTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        } else if let openDate = data.openTimestamp {
            func refreshTimeElapsed() {
                timeElapsed = Date().timeIntervalSince(openDate)
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                refreshTimeElapsed()
            }
        }
    }
    
    func addToCart(_ item: BillItem) {
        if item.is_rated {
            return
        }
        if !(animationTimer?.isValid ?? false)  {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true, block: { timer in
                withAnimation {
                    if rotateLeft == nil {
                        rotateLeft = true
                    } else {
                        rotateLeft?.toggle()
                    }
                }
                if selectedBillItems.isEmpty {
                    timer.invalidate()
                    rotateLeft = nil
                }
            })
        }
        withAnimation {
            if let count = selectedBillItems[item] {
                selectedBillItems[item] = count >= Int(item.count) ? Int(item.count) : count + 1
            } else {
                selectedBillItems[item] = 1
            }
        }
    }
    
    func createNewBill() {
        if selectedBillItems.isEmpty {
            return
        }
        let billData = BillData(asChildOf: data)
        addToBill(billData)
        if let taxItem = RatedPayableController.firstTaxRatedPayable(viewContext) {
            billData.addItem(taxItem, isAddOn: true)
        }
    }
    
    func addToBill(_ billData: BillData) {
        if selectedBillItems.isEmpty {
            return
        }
        billData.resignProceedBalance()
        billData.addItems(with: selectedBillItems)
        data.removeItems(items: selectedBillItems)
        clearCart()
        data.reloadChildren()
    }
    
    func clearCart() {
        selectedBillItems.removeAll()
    }
    
    func removeSubBill(_ bill: Bill) {
        if let items = bill.items?.allObjects as? [BillItem] {
            for item in items {
                if let payable = item.payable {
                    data.addItem(payable, count: Int(item.count), calculateRatedSubtotals: false)
                }
            }
        }
        data.removeSubBill(bill)
    }
    
    func reload() {
        data.reloadItems()
        data.calculateRatedSubtotals()
        data.reloadChildren()
    }
}
