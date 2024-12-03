////
////  SearchBar.swift
////  Spark
////
////  Created by Diego Lagunas on 11/29/24.
////
//
//import SwiftUI
//
//struct SearchBar: View {
//    @Binding var text: String
//    @State private var isEditing = false
//    var body: some View {
//        HStack {
//            TextField("Search", text: $text)
//                .padding(15)
//                .padding(.horizontal, 25)
//                .background(Color(.systemGray6))
//                .foregroundColor(.black)
//                .cornerRadius(8)
//                .overlay(
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                            .padding(.leading, 15)
//                        
//                        if isEditing {
//                            Button(action: {
//                                self.text = ""
//                            }, label: {
//                                Text("Button")
//                            })
//
//                        }
//                    })
//            
//        }
//    }
//}
////#Preview {
////    SearchBar(text: "Search")
////}
