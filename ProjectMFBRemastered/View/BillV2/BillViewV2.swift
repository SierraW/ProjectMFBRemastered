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
    @EnvironmentObject var shoppingData: PayableRatedPayableSelectionController
    
    @State var showDescriptionEditor = false
    @State var showSearchTagView = false
    
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
        Group {
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
                                Text("Details")
                                    .bold()
                                Spacer()
                            }
                            .foregroundColor(.gray)
                            .padding(.top)
                            .padding(.horizontal)
                            .onTapGesture {
                                showDescriptionEditor.toggle()
                            }
                            
                            Button {
                                showSearchTagView.toggle()
                            } label: {
                                Text(data.associatedTag == nil ? "Add Tag" : data.associatedTag!.toStringRepresentation)
                            }
                            
                            
                            ZStack {
                                TextEditor(text: $data.additionalDescription)
                                    .frame(idealHeight: 250)
                                    .padding()
                                if data.additionalDescription.isEmpty {
                                    VStack {
                                        HStack {
                                            Text("Leave a message about this bill...")
                                                .foregroundColor(.gray)
                                                .bold()
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                }
                                
                            }
                            
                        }
                        .sheet(isPresented: $showSearchTagView) {
                            TagSearchView { tag in
                                data.setAssociatedTag(tag)
                                showSearchTagView.toggle()
                            }
                        }
                    }
                
            }
        }
        .navigationTitle(data.name)
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
                            BillItemShoppingViewV2(controller: shoppingData) { payableDict, ratedPayableDict in
                                data.addItems(payableDict: payableDict, ratedPayableDict: ratedPayableDict)
                            }
                            .environmentObject(appData)
                            .navigationTitle("Select")
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                Text("Item")
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(shoppingData.status == .loading ? .yellow : shoppingData.status == .succeeded ? .green: .red)
                                Spacer()
                            }
                            .foregroundColor(.blue)
                        }
                        .disabled(shoppingData.status != .succeeded)
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
                                if data.bill.activeTag == nil {
                                    Button(role: .destructive) {
                                        data.setActive()
                                    } label: {
                                        Text("Active")
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                } else {
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
                                            selectedBill = nil
                                        }
                                        .environmentObject(appData)
                                        .environmentObject(billData)
                                        .environmentObject(shoppingData)
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
                        .frame(width: 160)
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
            refreshTimeElapsed()
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
        billData.addItems(with: selectedBillItems, isAddOn: true)
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
