//
//  ContentView.swift
//  Calculator
//
//  Created by Hirose Manabu on 2021/03/03.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var object: CalculatorSharedObject
    @State private var selection = 0

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                CalculatorNumeric()
                .tabItem {
                    VStack {
                        Image(systemName: "square.grid.3x3.bottomright.fill")
                        Text("Label_Numeric")
                    }
                }
                .tag(0)
                
                CalculatorUNIXTime()
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("Label_UNIX_Time")
                    }
                }
                .tag(1)
                
                CalculatorIPAddress()
                .tabItem {
                    VStack {
                        Image(systemName: "globe")
                        Text("Label_IP_Address")
                    }
                }
                .tag(2)
                
                CalculatorCharacters()
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Label_Characters")
                    }
                }
                .tag(3)
                
                CalculatorSettings()
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape.2")
                        Text("Label_Settings")
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
