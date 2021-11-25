//
//  RoomLandingView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-18.
//

import SwiftUI

struct BillSetupView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.managedObjectContext) private var viewContext
    
    var room: Tag
    
    @State var associatedTag: Tag? = nil
    @State var selectingTag = false
    
    @State var servicePayable: Payable? = nil
    @State var selectingPayable = false
    
    @State var numberOfPeople = ""
    
    @State var closed = false
    
    var onExit: (BillData) -> Void
    
    var body: some View {
        ZStack {
            NavigationLink("Product Selector", isActive: $selectingPayable) {
                PayableListView(dismissOnExit: true) { payable in
                    withAnimation {
                        servicePayable = payable
                        selectingPayable = false
                    }
                }
                .navigationTitle("Select a product...")
                .environmentObject(appData)
            }
            .hidden()
            NavigationLink("Tag Selector", isActive: $selectingTag) {
                TagListView(sortType: .highlighted, dismissOnExit: true) { tag in
                    withAnimation {
                        associatedTag = tag
                        selectingTag = false
                    }
                }
                .navigationTitle("Select a Tag...")
            }
            .hidden()
            Form {
                
                Section {
                    HStack {
                        Text("Tagged As")
                        Spacer()
                        Button {
                            selectingTag.toggle()
                        } label: {
                            Text(associatedTag?.toStringRepresentation ?? "Not Set")
                        }
                    }
                } header: {
                    Text("Tag")
                }
                
                Section {
                    HStack {
                        Text("Product")
                            .frame(width: 200, alignment: .leading)
                        Spacer()
                        Button {
                            selectingPayable.toggle()
                        } label: {
                            Text(servicePayable?.toStringRepresentation ?? "Not Set")
                        }
                    }
                    if servicePayable != nil {
                        HStack {
                            Text("Number Of People")
                                .frame(width: 200, alignment: .leading)
                            Spacer()
                            DecimalField(placeholder: "Required", textAlignment: .trailing, limitToPlaces: 0, value: $numberOfPeople)
                        }
                    }
                    
                } header: {
                    Text("One-time service payment")
                } footer: {
                    Text("Optional")
                }
                
                Section {
                    Button {
                        if closed {
                            return
                        }
                        closed = true
                        onExit(BillData(context: viewContext, tag: room, associatedTag: associatedTag, payable: servicePayable, size: Int(numberOfPeople) ?? 0))
                    } label: {
                        Text("Submit")
                    }

                }
            }
        }
        .navigationTitle(Text(room.toStringRepresentation))
    }
}
