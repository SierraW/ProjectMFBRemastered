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
    
    @State var servicePayable: Payable? = nil
    
    @State var numberOfPeople = ""
    
    @State var closed = false
    
    var onExit: (BillData) -> Void
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    NavigationLink {
                        TagSearchView { tag in
                            associatedTag = tag
                        }
                    } label: {
                        HStack {
                            Text("Tag")
                            Spacer()
                            Text(associatedTag?.toStringRepresentation ?? "Not Set")
                                .foregroundColor(.blue)
                        }
                    }
                } header: {
                    Text("Associated Tag")
                } footer: {
                    if associatedTag != nil {
                        HStack {
                            Spacer()
                            Button(role: .destructive) {
                                associatedTag = nil
                            } label: {
                                Text("Remove Tag")
                        }
                        }
                    }
                }
                
                Section {
                    NavigationLink {
                        PayableListView(dismissOnExit: true) { payable in
                            withAnimation {
                                servicePayable = payable
                            }
                        }
                        .navigationTitle("Select a product...")
                        .environmentObject(appData)
                    } label: {
                        HStack {
                            Text("Product")
                                .frame(width: 200, alignment: .leading)
                            Spacer()
                            Text(servicePayable?.toStringRepresentation ?? "Not Set")
                                .foregroundColor(.blue)
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
                }  footer: {
                    if servicePayable != nil {
                        HStack {
                            Spacer()
                            Button(role: .destructive) {
                                servicePayable = nil
                            } label: {
                                Text("Remove Product")
                            }
                        }
                    }
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
