//
//  RoomLandingView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-18.
//

import SwiftUI

struct BillLandingView: View {
    @EnvironmentObject var appData: AppData
    
    var room: Tag
    
    @State var associatedTag: Tag? = nil
    @State var selectingTag = false
    
    @State var servicePayable: Payable? = nil
    @State var selectingPayable = false
    
    @State var numberOfPeople = ""
    
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
                            Text(associatedTag?.toStringPresentation ?? "Not Set")
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
                            Text(servicePayable?.toStringPresentation ?? "Not Set")
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
                        //
                    } label: {
                        Text("Submit")
                    }

                }
            }
        }
        .navigationTitle(Text(room.toStringPresentation))
    }
}
