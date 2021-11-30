//
//  SBPTestFloatView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-29.
//

import SwiftUI

extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}

struct SBPTestFloatView: View {
    
    @State var showCartView = false
    
    @State var scaleValue: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Form {
                    Section {
                        ForEach(0...100, id: \.self) { index in
                            Button {
                                //
                            } label: {
                                HStack {
                                    Text("Row")
                                    Spacer()
                                    Text("\(index)")
                                }
                            }
                        }
                    } header: {
                        Text("test")
                    }
                }
                .zIndex(0)
                
                ZStack {
                    if showCartView {
                        Color.gray.opacity(0.3).ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showCartView.toggle()
                                }
                            }
                            .zIndex(1)
                        VStack {
                            VStack {
                                Text("Cart Items")
                                ScrollView {
                                    ForEach(0...10, id: \.self) { index in
                                        Button {
                                            //
                                        } label: {
                                            HStack {
                                                Text("Row")
                                                Spacer()
                                                Text("\(index)")
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.systemBackground)))
                            .padding(.horizontal, 7)
                        }
                        .padding(.top, 200)
                        .padding(.bottom, 200)
                        .transition(.moveAndFade)
                        .zIndex(2)
                    }
                    
                    VStack {
                        Spacer()
                        if showCartView {
                            Button(role: .destructive) {
                                //
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "trash")
                                    Text("Clear Cart")
                                        .frame(width: 95)
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                            }
                            .padding(.horizontal)
                            
                            Button {
                                //
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "plus")
                                    Text("New Bill").frame(width: 95)
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                            }
                            .padding(.horizontal)
                            
                            Button {
                                //
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "cart.badge.plus")
                                    Text("Existing Bill").frame(width: 95)
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                            }
                            .padding(.horizontal)
                        }
                        
                        HStack {
                            Button {
                                withAnimation {
                                    showCartView.toggle()
                                }
                                scaleValue = 0
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "cart")
                                    Text("View Cart").frame(width: 95)
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                            }
                            .padding(.horizontal)
                            
                            if !showCartView {
                                Button {
                                    //
                                } label: {
                                    Image(systemName: "plus")
                                        .padding(10)
                                        .background(Circle().fill(Color(UIColor.systemGray5)))
                                }
                                .scaleEffect(scaleValue)
                                .transition(.moveAndFade)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        scaleValue = 1
                                    }
                                }
                                Button {
                                    //
                                } label: {
                                    Image(systemName: "cart.badge.plus")
                                        .padding(10)
                                        .background(Circle().fill(Color(UIColor.systemGray5)))
                                }
                                .scaleEffect(scaleValue)
                                .transition(.scale.combined(with: .opacity))
                                Button(role: .destructive) {
                                    //
                                } label: {
                                    Image(systemName: "trash")
                                        .padding(10)
                                        .background(Circle().fill(Color(UIColor.systemGray5)))
                                }
                                .scaleEffect(scaleValue)
                                .transition(.scale.combined(with: .opacity))
                                .padding(.trailing)
                            }
                           
                        }
                    }
                    .zIndex(3)
                }
                
                
            }
        }
    }
}

struct SBPTestFloatView_Previews: PreviewProvider {
    static var previews: some View {
        SBPTestFloatView()
    }
}
