//
//  BillItemShoppingViewV2.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-28.
//

import SwiftUI

struct BillItemShoppingViewV2: View {
    enum Mode {
        case payable
        case ratedPayable
    }
    
    enum SortingRule {
        case frequent
        case name
        case price
    }
    
    @EnvironmentObject var appData: AppData
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var searchString = ""
    @State var mode: Mode = .payable
    @State var rule: SortingRule = .frequent
    
    var payables: [Payable] {
        var items = controller.payables
        switch rule {
        case .frequent:
            items.sort {
                ($0.starred && !$1.starred) ? true : ($0.billItems?.count ?? 0) > ($1.billItems? .count ?? 0)
            }
        case .name:
            items.sort {
                ($0.starred && !$1.starred) ? true : ($0.toStringRepresentation) < ($1.toStringRepresentation)
            }
        case .price:
            items.sort {
                ($0.starred && !$1.starred) ? true : ($0.amount as Decimal? ?? 0) > ($1.amount as Decimal? ?? 0)
            }
        }
        if searchString.isEmpty {
            return items
        } else {
            return items.filter({$0.toStringRepresentation.contains(searchString)})
        }
    }
    
    var ratedPayables: [RatedPayable] {
        var items = controller.ratedPayables
        switch rule {
        case .frequent:
            items.sort {
                ($0.starred && !$1.starred) ? true : ($0.billItems?.count ?? 0) > ($1.billItems? .count ?? 0)
            }
        case .name:
            items.sort {
                ($0.starred && !$1.starred) ? true : ($0.toStringRepresentation) < ($1.toStringRepresentation)
            }
        case .price:
            items.sort {
                ($0.starred && !$1.starred) ? true : ($0.rate as Decimal? ?? 0) > ($1.rate as Decimal? ?? 0)
            }
        }
        if searchString.isEmpty {
            return items
        } else {
            return items.filter({$0.toStringRepresentation.contains(searchString)})
        }
    }
    
    @State var selectedPayables: [Payable: Int] = [:]
    @State var selectedRatedPayables: [RatedPayable: Int] = [:]
    
    @State var showCart = false
    
    var floatingButtonSize: CGFloat = 10
    
    var isCartNotEmpty: Bool {
        !selectedPayables.isEmpty || !selectedRatedPayables.isEmpty
    }
    
    var cartItemsCount : Int {
        var count = 0
        selectedPayables.forEach { count += $1}
        selectedRatedPayables.forEach { count += $1}
        return count
    }
    
    var controller: PayableRatedPayableSelectionController
    var onSubmit: ([Payable: Int], [RatedPayable: Int]) -> Void
    
    var body: some View {
        ZStack {
            payableRatedPayableSection
            
            VStack {
                Spacer()
                floatingView
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .searchable(text: $searchString)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCart) {
            shoppingCartView
        }
    }
    
    var payableRatedPayableSection: some View {
        Form {
            if mode == .payable {
                Section {
                    ForEach(payables) { payable in
                        getPayableViewCell(payable)
                    }
                }
            } else {
                Section {
                    ForEach(ratedPayables) { ratedPayable in
                        getRatedPayableViewCell(ratedPayable)
                    }
                }
            }
            Spacer()
                .frame(height: floatingButtonSize)
                .listRowBackground(Color(uiColor: .systemGroupedBackground))
        }
    }
    
    func getPayableViewCell(_ payable: Payable) -> some View {
        HStack {
            Text(payable.toStringRepresentation)
            Spacer()
            if let count = selectedPayables[payable] {
                Image(systemName: "minus.circle")
                    .foregroundColor(.blue)
                    .padding(.leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            if count <= 1 {
                                selectedPayables.removeValue(forKey: payable)
                            } else {
                                selectedPayables[payable] = count - 1
                            }
                        }
                    }
                
                Text("\(count)")
                    .frame(width: 20)
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
                    .padding(.trailing)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPayables[payable] = count + 1
                    }
            }
            Text(appData.majorCurrency.toStringRepresentation)
                .frame(width: 50)
            HStack {
                Spacer()
                Text((payable.amount as Decimal?)?.toStringRepresentation ?? "Err")
            }
            .frame(width: 65)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedPayables[payable] = (selectedPayables[payable] ?? 0) + 1
            }
        }
    }
    
    func getRatedPayableViewCell(_ ratedPayable: RatedPayable) -> some View {
        HStack {
            Text(ratedPayable.toStringRepresentation)
            Spacer()
            if let _ = selectedRatedPayables[ratedPayable] {
                Text("1")
                    .frame(width: 20)
                Image(systemName: "minus.circle")
                    .foregroundColor(.blue)
                    .padding(.trailing)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedRatedPayables.removeValue(forKey: ratedPayable)
                    }
            }
            Group {
                Menu {
                    Text("This is a Rate Item")
                } label: {
                    Image(systemName: "r.square")
                        .foregroundColor(.red)
                }
                .frame(width: 50)
                HStack {
                    Spacer()
                    Text((ratedPayable.rate as Decimal?)?.toStringRepresentation ?? "Err")
                }
                .frame(width: 65)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedRatedPayables[ratedPayable] = (selectedRatedPayables[ratedPayable] ?? 0) + 1
            }
        }
    }
    
    var shoppingCartView: some View {
        VStack {
            HStack {
                Text("Cart")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
            Form {
                Section {
                    if selectedPayables.count == 0 {
                        Text("Empty...")
                            .foregroundColor(.gray)
                    }
                    ForEach(selectedPayables.keys.sorted()) { key in
                        HStack {
                            PayableViewCell(majorCurrency: appData.majorCurrency, payable: key)
                            Text("x \(selectedPayables[key] ?? 0)")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let count = selectedPayables[key] {
                                if count < 2 {
                                    selectedPayables.removeValue(forKey: key)
                                } else {
                                    selectedPayables[key] = count - 1
                                }
                            }
                        }
                    }
                } header: {
                    Text("Fix Value Items")
                }
                Section {
                    if selectedRatedPayables.count == 0 {
                        Text("Empty...")
                            .foregroundColor(.gray)
                    }
                    ForEach(selectedRatedPayables.keys.sorted()) { key in
                        HStack {
                            RatedPayableViewCell(ratedPayable: key)
                            Text("x \(selectedRatedPayables[key] ?? 0)")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let count = selectedRatedPayables[key] {
                                if count < 2 {
                                    selectedRatedPayables.removeValue(forKey: key)
                                } else {
                                    selectedRatedPayables[key] = count - 1
                                }
                            }
                        }
                    }
                } header: {
                    Text("Rate Items")
                }
            }
            Button {
                submit()
            } label: {
                SubmitButtonView(title: "Submit", foregroundColor: .white, backgroundColor: .blue)
            }
            .padding(.bottom)
            Button(role: .destructive) {
                selectedPayables.removeAll()
                selectedRatedPayables.removeAll()
                showCart = false
            } label: {
                Text("Clear")
            }
            .padding(.bottom)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var floatingView: some View {
        HStack {
            if isCartNotEmpty {
                Button {
                    showCart = true
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "cart.fill")
                        Text("View Cart")
                        if cartItemsCount <= 50 {
                            Image(systemName: "\(cartItemsCount).square.fill")
                                .foregroundColor(.red)
                                .scaledToFit()
                        } else {
                            Image(systemName: "tablecells.fill.badge.ellipsis")
                                .foregroundColor(.red)
                                .scaledToFit()
                        }
                        Spacer()
                    }
                    .frame(height: 30)
                    .padding(.vertical, floatingButtonSize)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                }
                .transition(.moveAndFade)
                
                Button {
                    selectedPayables.removeAll()
                    selectedRatedPayables.removeAll()
                } label: {
                    Image(systemName: "trash.fill")
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundColor(.red)
                        .padding(floatingButtonSize)
                        .background(Circle().fill(Color(UIColor.systemGray5)))
                }
                .padding(.leading)
            } else {
                Spacer()
            }
            
            Button(action: {
                if rule == .frequent {
                    rule = .price
                } else if rule == .price {
                    rule = .name
                } else {
                    rule = .frequent
                }
            }, label: {
                Image(systemName: rule == .frequent ? "flame.fill" : rule == .name ? "person.text.rectangle.fill" : "dollarsign.circle.fill" )
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(.red)
                    .padding(floatingButtonSize)
                    .background(Circle().fill(Color(UIColor.systemGray5)))
            })
                .contextMenu(menuItems: {
                    Button {
                        rule = .frequent
                    } label: {
                        Image(systemName: "flame.fill")
                        Text("Sort by frequency")
                    }
                    Button {
                        rule = .price
                    } label: {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("Sort by price")
                    }
                    Button {
                        rule = .name
                    } label: {
                        Image(systemName: "person.text.rectangle.fill")
                        Text("Sort by name")
                    }
                })
                .padding(.leading)
            
            Button(action: {
                if mode == .payable {
                    mode = .ratedPayable
                } else {
                    mode = .payable
                }
            }, label: {
                Image(systemName: mode == .payable ? "p.circle.fill" : "r.circle.fill")
                    .frame(width: 30, height: 30, alignment: .center)
                    .padding(floatingButtonSize)
                    .background(Circle().fill(Color(UIColor.systemGray5)))
            })
                .contextMenu(menuItems: {
                    Button {
                        mode = .payable
                    } label: {
                        Image(systemName: "p.circle.fill")
                        Text("Show Product")
                    }
                    Button {
                        mode = .ratedPayable
                    } label: {
                        Image(systemName: "r.circle.fill")
                        Text("Show Rated Items")
                    }
                })
                .padding(.leading)
            
            if isCartNotEmpty {
                Button(action: {
                    submit()
                }, label: {
                    Image(systemName: "checkmark")
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(floatingButtonSize)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.green))
                })
                    .padding(.leading)
            }
        }
    }
    
    func getItemViewCell(_ item: BillItem) -> some View {
        HStack {
            Text(item.toStringRepresentation)
            Spacer()
            Text("x \(item.count)")
                .padding(.trailing)
            if let amount = item.subtotal as Decimal? {
                Text(appData.majorCurrency.toStringRepresentation)
                Text(amount.toStringRepresentation)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .contentShape(Rectangle())
    }
    
    func submit() {
        showCart = false
        if cartItemsCount > 0 {
            onSubmit(selectedPayables, selectedRatedPayables)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
