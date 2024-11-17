//
//  SplashScreen.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    var body: some View {
        if isActive{
            ContentView()
        }else{
            VStack{
                VStack{
                    Image( "Logo")
                        .foregroundColor(.purple)
                        .scaleEffect(CGSize(width: 0.5, height: 0.5))
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear{
                            withAnimation(.easeIn(duration: 3.0)){
                                self.size = 1.2
                                self.opacity = 1.0
                                
                            }
                        }
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
            //space change for testing purposes
        }
    }
    //this is a test push for Ahmed
    struct SplashScreenView_Previews: PreviewProvider{
        static var previews: some View{
            SplashScreen()
        }
    }
}
