//
//  ContentView.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var object: CalcSharedObject
    @State private var selection = 0

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                CalcCalculator()
                .tabItem {
                    VStack {
                        Image(systemName: "square.grid.3x3.bottomright.fill")
                        Text("Calculator")
                    }
                }
                .tag(0)
                
                CalcUNIXTime()
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("UNIX Time")
                    }
                }
                .tag(1)
                
                CalcIPAddress()
                .tabItem {
                    VStack {
                        Image(systemName: "globe")
                        Text("IP Address")
                    }
                }
                .tag(2)
                
                CaclCharacter()
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Character")
                    }
                }
                .tag(3)
                
                CalcSetting()
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape.2")
                        Text("Setting")
                    }
                }
                .tag(4)
            }
            .blur(radius: object.isAlerting ? 2 : 0)
            .alert(isPresented: self.$object.isPopAlert) {
                Alert(title: Text(self.object.alertMessage), message: Text(self.object.alertDetail))
            }
            
            VStack() {
                Text(object.alertMessage)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(7)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(.systemBackground))
                    .background(Color(.label).opacity(0.85))
                    .cornerRadius(20.0)
                Spacer()
            }
            .padding(.top, 4)
            .padding(.horizontal, 20)
            .animation(.linear)
            .offset(y: object.isAlerting ? 0 : -150)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
