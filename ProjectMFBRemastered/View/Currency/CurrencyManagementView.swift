//
//  CurrencyManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import SwiftUI

struct CurrencyManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Currency.name, ascending: true)],
        animation: .default)
    private var fetchedCurrencies: FetchedResults<Currency>
    
    var currencies: [Currency] {
        switch sortType {
        case .symbol:
            return fetchedCurrencies.sorted { lhs, rhs in
                lhs.symbol ?? "" < rhs.symbol ?? ""
            }
        default:
            return fetchedCurrencies.map({$0})
        }
    }
    
    var controller: CurrencyController {
        CurrencyController(viewContext)
    }
    
    @State var majorCurrencyLocked = false
    @State var selectedMajorCurrencyIndex = -1
    @State var editingCurrencyIndex: Int? = nil
    
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Name"
        case symbol = "Symbol"
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        Text("Major Currency")
                        Spacer()
                        Picker("", selection: $selectedMajorCurrencyIndex) {
                            Text("Not Set").tag(-1)
                            ForEach(currencies.indices, id: \.self) {index in
                                Text(currencies[index].toStringPresentation).tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedMajorCurrencyIndex, perform: { newValue in
                            if selectedMajorCurrencyIndex >= 0 {
                                controller.assignMajorCurrency(with: currencies[newValue], from: currencies)
                            }
                        })
                        .disabled(majorCurrencyLocked)
                        .onAppear {
                            if let index = CurrencyController.getMajorCurrencyIndex(from: currencies) {
                                withAnimation {
                                    majorCurrencyLocked = true
                                    selectedMajorCurrencyIndex = index
                                }
                            }
                        }
                    }
                } header: {
                    Text("Settings")
                }

                Section {
                    ForEach(currencies.indices, id:\.self) { index in
                        HStack {
                            Text(currencies[index].toStringPresentation)
                            Spacer()
                            if !currencies[index].is_major, let rate = currencies[index].rate as Decimal? {
                                Text("Exchange rate:")
                                Text(rate.toStringPresentation)
                                    .frame(width: 40)
                            }
                        }
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                controller.delete(currencies[index])
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }
                                
                            }
                            .disabled(currencies[index].is_major)
                        }
                        .onTapGesture {
                            if editingCurrencyIndex == nil {
                                editingCurrencyIndex = index
                            }
                        }
                    }
                } header: {
                    Text("Currency List")
                }
            }
            Spacer()
            
            HStack {
                Button {
                    withAnimation {
                        editingCurrencyIndex = -1
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add new currency")
                    }
                    
                }
                .padding()
                Spacer()
            }
            
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $editingCurrencyIndex) { index in
            VStack {
                HStack {
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.gray)
                        .frame(width:50)
                    Spacer()
                    Text("Currency Editor")
                        .bold()
                    Spacer()
                    Spacer()
                        .frame(width:50)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        editingCurrencyIndex = nil
                    }
                }
                .padding()
                CurrencyEditionView(controller: controller, currency: index == -1 ? nil : currencies[index], currencies: currencies, onDelete: { currency in
                    withAnimation {
                        editingCurrencyIndex = nil
                        controller.delete(currency)
                    }
                }, onExit: {
                    withAnimation {
                        editingCurrencyIndex = nil
                    }
                })
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Menu {
                        ForEach(SortType.allCases, id:\.rawValue) { sortType in
                            Button {
                                self.sortType = sortType
                            } label: {
                                HStack {
                                    Text(sortType.rawValue)
                                    if self.sortType == sortType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text("Alignment")
                        }
                    }
                    Button(role: .destructive) {
                        majorCurrencyLocked = false
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Change Major Currency")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

struct CurrencyManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CurrencyManagementView()
                .preferredColorScheme(.light)
        }
    }
}
