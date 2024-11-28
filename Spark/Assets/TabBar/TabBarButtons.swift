//
//  TabBarButtons.swift
//  Spark
//
//  Created by Edison Chiu on 11/20/24.
//

import SwiftUI

struct TabBarButtons: View {
    
    var buttonText: String
    var imageName: String
    var isActive: Bool
    
    var body: some View {
        GeometryReader { geo in
            if isActive {
                Rectangle()
                    .foregroundColor(Color(hue: 0.725, saturation: 0.5, brightness: 0.912))
                    .frame(width: geo.size.width / 2, height: 4)
                    .padding(.leading, geo.size.width / 4)
            }
            
            VStack(alignment: .center, spacing: 4) {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                Text(buttonText)
                    .font(Font.custom("LexendDeca-Regular", size: 10))
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .padding(.bottom, 10)
        }
    }
}
